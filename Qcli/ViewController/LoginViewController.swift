//
//  LoginOAuthViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/09.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var notLoginButton: UIButton!
    let cornerRadiusValue: CGFloat = 8
    let userInfoKeychain = KeyChain()
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
//        if let _ = UserDefaults.standard.object(forKey: "isLogined") {
//            performSegue(withIdentifier: "toTabBarController", sender: nil)
//        }
        
    }
    
    @IBAction func login(_ sender: Any) {
        let token = self.getToken()
        let authRequest = AuthDataNetworkService(token: token)
        authRequest.fetch(success: { (userData) in
            if let id = userData.id {
                print("Authentication was successful with id = \(id).")
                //keychainにトークン情報を保存
                if let token = token {
                    self.userInfoKeychain.set(token: token)
                } else {
                    UserDefaults.standard.set(false, forKey: "isLogined")
                }
                //認証成功した場合は次の画面に遷移する
                self.performSegue(withIdentifier: "toTabBarController", sender: nil)
            } else {
                print(userData)
                print("Authentication was successful, but the id cannot be read.")
                UserDefaults.standard.set(false, forKey: "isLogined")
                self.displayMyAlertMessage(userMessage: "リクエストは送信できましたが、無効なトークンです。")
            }
        }, failure: { (error) in
            print("Authentication failed.")
            print(error)
            UserDefaults.standard.set(false, forKey: "isLogined")
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
        
    //リクエスト失敗した時用のアラート
    func displayMyAlertMessage(userMessage: String) {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle:  UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler:nil)
        myAlert.addAction(okAction);
        self.present(myAlert,animated:true, completion:nil)
        
    }
    
    func getToken() -> String? {
        return self.tokenTextField.text
    }
    
}
