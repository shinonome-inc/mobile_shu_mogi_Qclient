//
//  FeedViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/13.
//

import UIKit

class FeedViewController: UIViewController {

    @IBOutlet weak var searchTxextField: UITextField!
    let cornerRadiusValue: CGFloat = 8
    override func viewDidLoad() {
        super.viewDidLoad()
        //ログインした状態ならユーザー情報呼び出し
        if self.isLogined() {
            let token = callUserInfo()
            print("トークン読み込みました\(token)")
        }
    }
    
    //userInfo呼び出し
    func callUserInfo() -> qiitaUserInfo {
        var value = qiitaUserInfo(token: "")
        if let data = UserDefaults.standard.value(forKey:"userInfo") as? Data {
            let userInfo = try? PropertyListDecoder().decode(Array<qiitaUserInfo>.self, from: data)
            if let userInfo = userInfo {
                value = userInfo[0]
            }
        }
        return value
    }
    
    //ログイン判定
    func isLogined() -> Bool {
        var value = false
        value = UserDefaults.standard.bool(forKey: "isLogined")
        return value
    }
    
    func setLayout() {
        searchTxextField.layer.cornerRadius = cornerRadiusValue
    }
    
}
