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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfile()
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
            if let sendUserListType = self.sendUserListType,
               let userId = self.userId {
                userListVC.userListType = sendUserListType
                userListVC.userId = userId
            }
        }
        
        if (segue.identifier == SegueId.fromMyPageToArticlePage.rawValue) {
            let articlePageVC = segue.destination as! ArticlePageViewController
            if let sendData = self.sendData {
                articlePageVC.articleData = sendData
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
                   let articleURL = oneAirticleData.url {
                    let oneData = ArticleData(imgURL: imageURL, titleText: title, createdAt: createdAt, likeNumber: like, articleURL: articleURL)
                    self.dataItems.append(oneData)
                } else {
                    print("ERROR: This data ↓ allocation failed.")
                    print(oneAirticleData)
                }
            }
            self.articleTableView.reloadData()
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
        let keychain = KeyChain()
        guard let token = keychain.get() else { return }
        let authRequest = AuthDataNetworkService(token: token)
        setUserInfo(request: authRequest)
    }
    
    func setUserInfo(request: AuthDataNetworkService) {
        request.fetch(success: { (userData) in
            if let id = userData.id {
                self.userId = id
                self.userIdLabel.text = "@\(id)"
                self.myItemDataRequest = AirticleDataNetworkService(searchDict: [SearchOption.user: id])
                self.getData(requestAirticleData: self.myItemDataRequest)
            }
            if let name = userData.name {
                self.userNameLabel.text = name
            }
            if let userDiscription = userData.description {
                self.userDiscriptionLabel.text = userDiscription
            }
            if let followNumber = userData.followeesCount {
                self.followButton.setTitle(" \(followNumber) Follow ", for: .normal)
                if followNumber <= 0 {
                    self.followButton.isEnabled = false
                }
            }
            if let followerNumber = userData.followersCount {
                self.follwerButton.setTitle(" \(followerNumber) Follower ", for: .normal)
                if followerNumber <= 0 {
                    self.follwerButton.isEnabled = false
                }
            }
            if let imgUrl = userData.profileImageUrl,
               let url = URL(string: imgUrl) {
                self.userImageView.setImage(with: url, completionHandler: { result in
                    switch result {
                    case .success(_): break
                    case .failure(_):
                        self.userImageView.image = UIImage(named: "no-coupon-image.png")
                    }
                })
            }
        }, failure: { (error) in
            print("↓ Could not call profile.")
            print(error)
            //TODO: エラー画面を作成し、遷移させる
        })
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
        
        if distanceToBottom < 150 && self.isNotLoading {
            self.isNotLoading = false
            self.pageCount += 1
            self.myItemDataRequest.pageNumber = self.pageCount
            self.getData(requestAirticleData: self.myItemDataRequest)
            
        }
    }
    
    
}
