//
//  UserListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/31.
//

import UIKit

class UserListViewController: UIViewController {
    
    @IBOutlet weak var userListCollectionView: UICollectionView!
    @IBOutlet weak var userTypeSegmentedControl: UISegmentedControl!
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
    //segmented control
    let segmentedTypeItems = UserListType.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromUserListToUserDetail.rawValue) {
            let userDetailVC = segue.destination as! UserDetailViewController
            if let sendData = sendData {
                userDetailVC.receivedData = sendData
            }
        }
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
            self.userListCollectionView.reloadData()
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
}

extension UserListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = userListCollectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as? UserListCollectionViewCell else {
            abort()
        }
        let model = dataItems[indexPath.row]
        cell.setModel(model: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sendData = dataItems[indexPath.row]
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueId.fromUserListToUserDetail.rawValue, sender: nil)
    }
    
    //collectionviewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
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

