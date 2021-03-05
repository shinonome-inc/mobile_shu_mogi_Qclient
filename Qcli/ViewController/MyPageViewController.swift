//
//  MyPageViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/29.
//

import UIKit

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userDiscriptionLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var follwerButton: UIButton!
    @IBOutlet weak var articleTableView: UITableView!
    
    //取得する記事データのリスト
    var dataItems = [ArticleData]()
    //UserListVC用受け渡しデータ
    var sendUserListType: UserListType?
    //画面遷移時のデータ受け渡し用
    var sendData: ArticleData?
    //データリクエストの宣言
    var myItemDataRequest: AirticleDataNetworkService!
    //スクロールデータ更新用のページカウント
    var pageCount = 1
    //リクエストできる状態か判定
    var isNotLoading = false
    //データリクエスト時に扱うユーザーID
    var userId: String?
    //ユーザーの名前
    var userName: String?
    //キーチェーン
    var keychain = KeyChain()
    //set refreshControl
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keychain.errorDelegate = self
        toggleUserItems()
        setProfile()
        //set refresh control
        articleTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        sendUserListType = .follow
        pushUserListViewController()
    }
    
    @IBAction func follwerButtonTapped(_ sender: Any) {
        sendUserListType = .follower
        pushUserListViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromMyPageToArticlePage.rawValue) {
            if let navigationController = segue.destination as? UINavigationController,
               let articlePageViewController = navigationController.topViewController as? ArticlePageViewController,
               let sendData = sendData {
                articlePageViewController.articleData = sendData
            }
        }
    }
    
    func pushUserListViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let myNavigationController = storyboard.instantiateViewController(withIdentifier: "UserList") as! MyNavigationController
        let userListVC = myNavigationController.topViewController as! UserListViewController
        if let sendUserListType = sendUserListType,
           let userId = userId,
           let userName = userName,
           let navigationController = navigationController {
            userListVC.userListType = sendUserListType
            userListVC.userId = userId
            userListVC.userName = userName
            navigationController.pushViewController(userListVC, animated: true)
        }
    }
    
    //apiを叩きデータを保存する
    func getData(requestAirticleData: AirticleDataNetworkService, isRefresh: Bool = false) {
        requestAirticleData.fetch(success: { (dataArray) in
            self.refreshControl.endRefreshing()
            guard let dataArray = dataArray else { return }
            let convertedModels = self.storingData(dataArray: dataArray)
            if isRefresh {
                self.dataItems = convertedModels
            } else {
                self.dataItems += convertedModels
            }
            self.articleTableView.reloadData()
            print("👍 Reload the article data")
            self.isNotLoading = true
        }, failure: { error in
            self.refreshControl.endRefreshing()
            print("Failed to get the article list data.")
            if let error = error {
                print(error)
            }
            self.isNotLoading = true
            //TODO: エラー画面を作成し、遷移させる
        })
    }
    
    func storingData(dataArray: [AirticleModel]) -> [ArticleData] {
        var models: [ArticleData] = []
        dataArray.forEach { (oneAirticleData) in
            if let title = oneAirticleData.title,
               let createdAt = oneAirticleData.createdAt,
               let like = oneAirticleData.likesCount,
               let imageURL = oneAirticleData.user.profileImageUrl,
               let articleURL = oneAirticleData.url,
               let id = oneAirticleData.user.id {
                let oneData = ArticleData(id: id, imgURL: imageURL, titleText: title, createdAt: createdAt, likeNumber: like, articleURL: articleURL)
                models.append(oneData)
            } else {
                print("ERROR: This data ↓ allocation failed.")
                print(oneAirticleData)
            }
        }
        return models
    }
    
    func setProfile() {
        guard let token = keychain.get() else { return }
        let authRequest = AuthDataNetworkService(token: token)
        authRequest.fetch(success: { (userData) in
            self.setUserInfo(userData: userData)
        }, failure: { (error) in
            print("↓ Could not call profile.")
            print(error)
            //TODO: エラー画面を作成し、遷移させる
        })
    }
    
    func setUserInfo(userData: UserModel) {
        if let id = userData.id {
            userId = id
            userIdLabel.text = "@\(id)"
            myItemDataRequest = AirticleDataNetworkService(searchDict: [SearchOption.user: id])
            getData(requestAirticleData: myItemDataRequest)
        }
        if let name = userData.name,
           let id = userData.id {
            if name == "" {
                userName = id
                userNameLabel.text = id
            } else {
                userName = name
                userNameLabel.text = name
            }
        }
        if let userDiscription = userData.description {
            userDiscriptionLabel.text = userDiscription
        }
        if let followNumber = userData.followeesCount {
            followButton.setMutableAttributedString(number: String(followNumber), unit: " フォロー中")
            if followNumber <= 0 {
                followButton.isEnabled = false
            }
        }
        if let followerNumber = userData.followersCount {
            follwerButton.setMutableAttributedString(number: String(followerNumber), unit: "フォロワー")
            if followerNumber <= 0 {
                follwerButton.isEnabled = false
            }
        }
        if let imgUrl = userData.profileImageUrl,
           let url = URL(string: imgUrl) {
            userImageView.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(_): break
                case .failure(_):
                    self.self.userImageView.image = UIImage(named: "no-coupon-image.png")
                }
            })
        }
        toggleUserItems()
    }
    
    @objc func refresh() {
        pageCount = 1
        myItemDataRequest.pageNumber = pageCount
        getData(requestAirticleData: myItemDataRequest, isRefresh: true)
    }
    
    func toggleUserItems() {
        userNameLabel.isHidden = !userNameLabel.isHidden
        userIdLabel.isHidden = !userIdLabel.isHidden
        userImageView.isHidden = !userImageView.isHidden
        userDiscriptionLabel.isHidden = !userDiscriptionLabel.isHidden
        followButton.isHidden = !followButton.isHidden
        follwerButton.isHidden = !follwerButton.isHidden
    }
}

extension MyPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = articleTableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? MyPageTableViewCell else {
            abort()
        }
        let model = dataItems[indexPath.row]
        cell.setModel(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendData = dataItems[indexPath.row]
        //tableviewcell選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueId.fromMyPageToArticlePage.rawValue, sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 150 && isNotLoading {
            isNotLoading = false
            pageCount += 1
            myItemDataRequest.pageNumber = pageCount
            getData(requestAirticleData: myItemDataRequest)
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return PostedArticleSectionView.setConfig()
    }
}

extension MyPageViewController: ErrorDelegate {
    func segueErrorViewController(qiitaError: QiitaError) {
        let errorView = ErrorView.make()
        errorView.checkSafeArea(viewController: self)
        errorView.errorDelegate = self
        errorView.qiitaError = qiitaError
        errorView.setConfig()
        view.addSubview(errorView)
    }
    
    func backToLoginViewController() {
        let identifier = ViewControllerIdentifier.login.rawValue
        if let storyboard = self.storyboard,
           let navigationController = self.navigationController {
            let loginViewController = storyboard.instantiateViewController(identifier: identifier) as! LoginViewController
            navigationController.pushViewController(loginViewController, animated: true)
        }
    }
    
    func reload() {        
    }
    
    
}
