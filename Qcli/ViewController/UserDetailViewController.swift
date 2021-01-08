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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userDetailData = self.receivedData else { return }
        setProfile(model: userDetailData)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        sendUserListType = .follow
        performSegue(withIdentifier: SegueId.fromUserDetailToUserList.rawValue, sender: nil)
    }
    
    @IBAction func FollowerButtonTapped(_ sender: Any) {
        sendUserListType = .follower
        performSegue(withIdentifier: SegueId.fromUserDetailToUserList.rawValue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromUserDetailToUserList.rawValue) {
            let userListVC = segue.destination as! UserListViewController
            if let sendUserListType = self.sendUserListType,
               let userId = self.userId {
                userListVC.userListType = sendUserListType
                userListVC.userId = userId
            }
        }
        
        if (segue.identifier == SegueId.fromUserDetailToArticlePage.rawValue) {
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
        })
    }
    
    func setProfile(model: UserDetailData) {
        
        self.userId = model.userId
        self.userIdLabel.text = "@\(model.userId)"
        self.myItemDataRequest = AirticleDataNetworkService(searchDict: [SearchOption.user: model.userId])
        self.getData(requestAirticleData: self.myItemDataRequest)
        
        self.userNameLabel.text = model.userName
        
        self.userDiscriptionLabel.text = model.discription
        
        self.followButton.setTitle(" \(model.followCount) Follow ", for: .normal)
        if model.followCount <= 0 {
            self.followButton.isEnabled = false
        }
        
        self.follwerButton.setTitle(" \(model.followerCount) Follower ", for: .normal)
        if model.followerCount <= 0 {
            self.follwerButton.isEnabled = false
        }
        
        if let url = URL(string: model.imageUrl) {
            self.userImageView.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(_): break
                case .failure(_):
                    self.userImageView.image = UIImage(named: "no-coupon-image.png")
                }
            })
        }
    }
}

extension UserDetailViewController: UITableViewDelegate {
    
}

extension UserDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataItems.count
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
        
        if distanceToBottom < 150 && self.isNotLoading {
            self.isNotLoading = false
            self.pageCount += 1
            self.myItemDataRequest.pageNumber = self.pageCount
            self.getData(requestAirticleData: self.myItemDataRequest)
            
        }
    }
}