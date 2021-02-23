//
//  UserListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/31.
//

import UIKit

class UserListViewController: UIViewController {
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var userTypeSegmentedControl: UISegmentedControl!
    //ユーザーリストのタイプ
    var userListType: UserListType?
    //ユーザーid
    var userId: String?
    //ユーザーの名前
    var userName: String?
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
    //segmented control
    let segmentedTypeItems = UserListType.allCases
    
    override func viewDidLoad() {
        if let navigationController = navigationController as? MyNavigationController {
            navigationController.setConfig()
        }
        super.viewDidLoad()
        if let userName = userName {
            title = userName
        }
        guard let userId = userId else {
            assertionFailure("userId → nil")
            return
        }
        guard let userListType = userListType else {
            assertionFailure("userListType → nil")
            return
        }
        userListDataRequest = UserListNetworlService(userType: userListType, userId: userId)
        getData(requestUserListData: userListDataRequest)
        setSegmentedControl(userListType: userListType)
    }
    
    @IBAction func tapSegmentedControl(_ sender: UISegmentedControl) {
        dataItems.removeAll()
        guard let userId = userId else { return }
        let selectedUserType = segmentedTypeItems[sender.selectedSegmentIndex]
        userListType = selectedUserType
        userListDataRequest = UserListNetworlService(userType: selectedUserType, userId: userId)
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
            //TODO: エラー画面を作成し、遷移させる
        })
    }
    
    func setSegmentedControl(userListType: UserListType) {
        userTypeSegmentedControl.removeAllSegments()
        let segmentedTitleItems = segmentedTypeItems.map { $0.title } //["フォロー中", "フォロワー"]
        for (index, title) in segmentedTitleItems.enumerated() {
            userTypeSegmentedControl.insertSegment(withTitle: title, at: index, animated: true)
        }
        //UISegmentedControlの選択状態を更新する
        if let nowSelectedIndex = segmentedTypeItems.firstIndex(of: userListType) {
            userTypeSegmentedControl.selectedSegmentIndex = nowSelectedIndex
        }
    }
    
    func pushUserDetailViewController(dataItem: UserDetailData) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let myNavigationController = storyboard.instantiateViewController(withIdentifier: "UserDetail") as! MyNavigationController
        let userDetailViewController = myNavigationController.topViewController as! UserDetailViewController
        userDetailViewController.receivedData = dataItem
        if let navigationController = navigationController {
            navigationController.pushViewController(userDetailViewController, animated: true)
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
        tableView.deselectRow(at: indexPath, animated: true)
        pushUserDetailViewController(dataItem: dataItems[indexPath.row])
    }
    
    //tableviewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 150 && isNotLoading {
            isNotLoading = false
            pageNumber += 1
            guard let userId = userId,
                  let userListType = userListType else { return }
            userListDataRequest = UserListNetworlService(userType: userListType, userId: userId)
            userListDataRequest.pageNumber = pageNumber
            getData(requestUserListData: userListDataRequest)
        }
    }
}

extension UserListViewController: UISearchBarDelegate {
    
}
