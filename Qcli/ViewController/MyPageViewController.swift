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
    var dataItems = [ArticleData]() {
        didSet {
            articleTableView.reloadData()
        }
    }
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
        navigationController!.setNavigationBarColor()
        keychain.errorDelegate = self
        hideUserItems()
        setProfile()
        //set refresh control
        articleTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        sendUserListType = .follow
        performSegue(withIdentifier: SegueId.fromMyPageToUserList.rawValue, sender: nil)
    }
    
    @IBAction func follwerButtonTapped(_ sender: Any) {
        sendUserListType = .follower
        performSegue(withIdentifier: SegueId.fromMyPageToUserList.rawValue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromMyPageToUserList.rawValue) {
            let userListVC = segue.destination as! UserListViewController
            if let sendUserListType = sendUserListType,
               let userId = userId,
               let userName = userName {
                userListVC.userListType = sendUserListType
                userListVC.userId = userId
                userListVC.userName = userName
            }
        }
        
        if (segue.identifier == SegueId.fromMyPageToArticlePage.rawValue) {
            if let navigationController = segue.destination as? UINavigationController,
               let articlePageViewController = navigationController.topViewController as? ArticlePageViewController,
               let sendData = sendData {
                articlePageViewController.articleData = sendData
            }
        }
    }
    
    //apiを叩きデータを保存する
    func getData(requestAirticleData: AirticleDataNetworkService) {
        requestAirticleData.fetch(success: { (dataArray) in
            dataArray?.forEach { (oneAirticleData) in
                if let title = oneAirticleData.title,
                   let createdAt = oneAirticleData.createdAt,
                   let like = oneAirticleData.likesCount,
                   let imageURL = oneAirticleData.user.profileImageUrl,
                   let articleURL = oneAirticleData.url,
                   let id = oneAirticleData.user.id {
                    let oneData = ArticleData(id: id, imgURL: imageURL, titleText: title, createdAt: createdAt, likeNumber: like, articleURL: articleURL)
                    self.dataItems.append(oneData)
                    print("dataItems appended")
                } else {
                    print("ERROR: This data ↓ allocation failed.")
                    print(oneAirticleData)
                }
            }
            print("👍 Reload the article data")
            self.isNotLoading = true
            
        }, failure: { error in
            print("Failed to get the article list data.")
            if let error = error {
                print(error)
            }
            self.isNotLoading = true
            //TODO: エラー画面を作成し、遷移させる
        })
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
            followButton.setAttributedTitle(setButtonTitle(number: String(followNumber), unit: " フォロー中"), for: .normal)
            if followNumber <= 0 {
                followButton.isEnabled = false
            }
        }
        if let followerNumber = userData.followersCount {
            follwerButton.setAttributedTitle(setButtonTitle(number: String(followerNumber), unit: " フォロワー"), for: .normal)
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
        showUserItems()
    }
    
    @objc func refresh() {
        dataItems.removeAll()
        pageCount = 1
        myItemDataRequest.pageNumber = pageCount
        getData(requestAirticleData: myItemDataRequest)
        articleTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func hideUserItems() {
        userNameLabel.isHidden = true
        userIdLabel.isHidden = true
        userImageView.isHidden = true
        userDiscriptionLabel.isHidden = true
        followButton.isHidden = true
        follwerButton.isHidden = true
    }
    
    func showUserItems() {
        userNameLabel.isHidden = false
        userIdLabel.isHidden = false
        userImageView.isHidden = false
        userDiscriptionLabel.isHidden = false
        followButton.isHidden = false
        follwerButton.isHidden = false
    }
    
    func setButtonTitle(number: String, unit: String) -> NSMutableAttributedString {
        let stringAttributes1: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.label,
            .font : UIFont.boldSystemFont(ofSize: 12.0)
        ]
        let string1 = NSAttributedString(string: number, attributes: stringAttributes1)

        let stringAttributes2: [NSAttributedString.Key : Any] = [
            .foregroundColor : #colorLiteral(red: 0.5097572207, green: 0.5098338723, blue: 0.5097404122, alpha: 1),
            .font : UIFont.systemFont(ofSize: 12.0)
        ]
        let string2 = NSAttributedString(string: unit, attributes: stringAttributes2)

        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(string1)
        mutableAttributedString.append(string2)
        
        return mutableAttributedString
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
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 12, y: 0, width: 320, height: 28)
        myLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        myLabel.textColor = #colorLiteral(red: 0.5097572207, green: 0.5098338723, blue: 0.5097404122, alpha: 1)
        myLabel.text = "投稿記事"
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: 320, height: 28)
        headerView.backgroundColor = Palette.tableViewSectionBackgroundColor
        headerView.addSubview(myLabel)
        
        return headerView
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
