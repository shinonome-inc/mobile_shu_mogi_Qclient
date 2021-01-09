//
//  UserListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/31.
//

import UIKit

class UserListViewController: UIViewController {
    
    @IBOutlet weak var userListTableView: UITableView!
    //ユーザーリストのタイプ
    var userListType: UserListType?
    //ユーザーid
    var userId: String?
    //取得するデータのリスト
    var dataItems = [UserDetailData]()
    //送信用データ
    var sendData: UserDetailData?
    //データリクエストの宣言
    var userListDataRequest: UserListNetworlService!
    //ページカウント
    var pageNumber = 1
    //リクエストできるか状態かの判定
    var isNotLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userId = self.userId else {
            assertionFailure("userId → nil")
            return
        }
        guard let userListType = self.userListType else {
            assertionFailure("userListType → nil")
            return
        }
        self.userListDataRequest = UserListNetworlService(userType: userListType, userId: userId)
        getData(requestUserListData: userListDataRequest)
    }
    
    //apiを叩きデータを保存する
    func getData(requestUserListData: UserListNetworlService) {
        requestUserListData.fetch(success: { (dataArray) in
            dataArray?.forEach { (oneUserListData) in
                if let name = oneUserListData.name,
                   let id = oneUserListData.id,
                   let imageURL = oneUserListData.profileImageUrl,
                   let itemCount = oneUserListData.itemsCount,
                   let followeesCount = oneUserListData.followeesCount,
                   let followersCount = oneUserListData.followersCount {
                    if let description = oneUserListData.description {
                        let oneData = UserDetailData(imageUrl: imageURL,
                                                     userName: name,
                                                     userId: id,
                                                     itemCount: itemCount,
                                                     discription: description,
                                                     followCount: followeesCount,
                                                     followerCount: followersCount)
                        self.dataItems.append(oneData)
                    } else {
                        let oneData = UserDetailData(imageUrl: imageURL,
                                                     userName: name,
                                                     userId: id,
                                                     itemCount: itemCount,
                                                     discription: "",
                                                     followCount: followeesCount,
                                                     followerCount: followersCount)
                        self.dataItems.append(oneData)
                    }
                    
                } else {
                    print("ERROR: This data ↓ allocation failed.")
                    print(oneUserListData)
                }
            }
            self.userListTableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromUserListToUserDetail.rawValue) {
            let userDetailVC = segue.destination as! UserDetailViewController
            if let sendData = self.sendData {
                userDetailVC.receivedData = sendData
            }
        }
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = userListTableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserListTableViewCell else {
            abort()
        }
        let model = dataItems[indexPath.row]
        cell.setModel(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendData = dataItems[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueId.fromUserListToUserDetail.rawValue, sender: nil)
    }
    
    //tableviewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 150 && self.isNotLoading {
            self.isNotLoading = false
            self.pageNumber += 1
            self.userListDataRequest.pageNumber = self.pageNumber
            self.getData(requestUserListData: self.userListDataRequest)        
        }
    }
}
