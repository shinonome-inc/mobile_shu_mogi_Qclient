//
//  UserDetailViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/03.
//

import UIKit

class UserDetailViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userDiscriptionLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var follwerButton: UIButton!
    @IBOutlet weak var articleTableView: UITableView!
    
    //UserListVCから受け取るデータ
    var receivedData: UserDetailData?
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
    //set refreshControl
    let refreshControl = UIRefreshControl()
    //UserListVCに受け渡し用
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = navigationController as? MyNavigationController {
            navigationController.setConfig()
        }
        guard let userDetailData = receivedData else { return }
        setProfile(model: userDetailData)
        //set refresh control
        articleTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        sendUserListType = .follow
        pushUserListViewController()
    }
    
    @IBAction func FollowerButtonTapped(_ sender: Any) {
        sendUserListType = .follower
        pushUserListViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromUserDetailToArticlePage.rawValue) {
            if let navigationController = segue.destination as? UINavigationController,
               let articlePageViewController = navigationController.topViewController as? ArticlePageViewController,
               let sendData = sendData {
                articlePageViewController.articleData = sendData
            }
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
    
    func setProfile(model: UserDetailData) {
        
        userId = model.userId
        userIdLabel.text = "@\(model.userId)"
        myItemDataRequest = AirticleDataNetworkService(searchDict: [SearchOption.user: model.userId])
        getData(requestAirticleData: myItemDataRequest)
        
        if model.userName == "" {
            userNameLabel.text = model.userId
            userName = model.userId
        } else {
            userNameLabel.text = model.userName
            userName = model.userName
        }
        
        userDiscriptionLabel.text = model.discription
        
        followButton.setMutableAttributedString(number: String(model.followCount), unit: "フォロー中")
        if model.followCount <= 0 {
            followButton.isEnabled = false
        }
        
        follwerButton.setMutableAttributedString(number: String(model.followerCount), unit: "フォロワー")
        if model.followerCount <= 0 {
            follwerButton.isEnabled = false
        }
        
        if let url = URL(string: model.imageUrl) {
            userImageView.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(_): break
                case .failure(_):
                    self.userImageView.image = UIImage(named: "no-coupon-image.png")
                }
            })
        }
    }
    
    @objc func refresh() {
        pageCount = 1
        myItemDataRequest.pageNumber = pageCount
        getData(requestAirticleData: myItemDataRequest, isRefresh: true)
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
}

extension UserDetailViewController: UITableViewDataSource, UITableViewDelegate {
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
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueId.fromUserDetailToArticlePage.rawValue, sender: nil)
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
