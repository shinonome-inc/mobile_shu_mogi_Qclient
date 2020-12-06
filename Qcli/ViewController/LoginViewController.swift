//
//  LoginOAuthViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/09.
//

import UIKit


struct qiitaUserInfo: Codable {
    var token: String
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var notLoginButton: UIButton!
    let cornerRadiusValue: CGFloat = 8
    var qiitaInfo: qiitaUserInfo!
    var result: [Any]!
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        testInput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //2回目のログインだとログインをスキップさせる
        if let _ = UserDefaults.standard.object(forKey: "isLogined") {
            performSegue(withIdentifier: "toTabBarController", sender: nil)
        }
        
    }
    
    @IBAction func login(_ sender: Any) {
        print("login button tapped")
        let userInfo = self.setUserInfo()
        let authRequest = RequestData(dataType: .auth, userInfo: userInfo)
        authRequest.isAuth(success: { (userData) in
            if let id = userData.id {
                print("Authentication was successful with id = \(id).")
                //認証成功した場合は次の画面に遷移する
                self.performSegue(withIdentifier: "toTabBarController", sender: nil)
            } else {
                print(userData)
                print("Authentication was successful, but the id cannot be read.")
                self.displayMyAlertMessage(userMessage: "リクエストは送信できましたが、無効なトークンです。")
            }
        }, failure: { (error) in
            print("Authentication failed.")
            print(error)
            self.displayMyAlertMessage(userMessage: "リクエスト送信できませんでした。")
        })
    }
    
    func setLayout() {
        tokenTextField.layer.cornerRadius = cornerRadiusValue
        loginButton.layer.cornerRadius = cornerRadiusValue
        notLoginButton.layer.cornerRadius = cornerRadiusValue
    }
    
    //テスト用トークン
    func testInput() {
        tokenTextField.text = "5826b1255becde9c13ed80bee2e510a979268d8f"
    }
    
    //トークン入力テキストフィールドからトークンを読み取る
    func setUserInfo() -> qiitaUserInfo {
        var info = qiitaUserInfo(token: "")
        if let token = self.tokenTextField.text {
            info.token = token
            return info
        }
        return info
    }
    
    //リクエスト失敗した時用のアラート
    func displayMyAlertMessage(userMessage: String) {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle:  UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler:nil)
        myAlert.addAction(okAction);
        self.present(myAlert,animated:true, completion:nil)
        
    }    
    
}
