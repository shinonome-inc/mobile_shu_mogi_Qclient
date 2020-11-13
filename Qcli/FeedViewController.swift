//
//  FeedViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/13.
//

import UIKit

class FeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isLogined() {
            
        }
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        if let data = UserDefaults.standard.value(forKey:"userInfo") as? Data {
            let userInfo = try? PropertyListDecoder().decode(Array<qiitaUserInfo>.self, from: data)
            if let userInfo = userInfo {
                print(userInfo[0].token)
            }
        } else {
            print("失敗")
        }
    }
    
    //userInfo呼び出し
    func callUserInfo() -> qiitaUserInfo {
        let value = qiitaUserInfo(token: "")
        return value
    }
    
    func isLogined() -> Bool {
        var value = false
        value = UserDefaults.standard.bool(forKey: "isLogined")
        return value
    }
}
