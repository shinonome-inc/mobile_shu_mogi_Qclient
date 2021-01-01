//
//  UserListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/31.
//

import UIKit

class UserListViewController: UIViewController {
    
    //ユーザーリストのタイプ
    var userListType: UserListType?
    //ユーザーid
    var userId: String?
    //取得するデータのリスト
    var dataItems = [UserData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
