//
//  LoginOAuthViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/09.
//

import UIKit
import Alamofire

struct qiitaUserInfo {
    var userID: String
    var password: String
    var token: String
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var notLoginButton: UIButton!
    let cornerRadiusValue: CGFloat = 8
    var qiitaInfo: qiitaUserInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLayout()
        testInput()
        print("立ち上げ成功")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //2回目のログインだとログインをスキップさせる
        if let _ = UserDefaults.standard.object(forKey: "userName") {
            performSegue(withIdentifier: "goTimeLine", sender: nil)
        }
    }
    
    @IBAction func login(_ sender: Any) {
        print("login button tapped")
        qiitaAuthentication(info: self.setUserInfo())
    }
    
    func setLayout() {
        userIDTextField.layer.cornerRadius = cornerRadiusValue
        passwordTextField.layer.cornerRadius = cornerRadiusValue
        tokenTextField.layer.cornerRadius = cornerRadiusValue
        loginButton.layer.cornerRadius = cornerRadiusValue
        notLoginButton.layer.cornerRadius = cornerRadiusValue
    }
    
    //ユーザー情報を入力して正し以下どうか判定
    func qiitaAuthentication(info: qiitaUserInfo) {
        print("qiitaAuthentication呼ばれました")
        let url: String = "https://qiita.com/api/v2/authenticated_user"
        let headers: HTTPHeaders = [
            "Authorization": "token " + info.token
        ]
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            switch response.result {
            case .success:
                print("成功")
            case .failure:
                print("失敗")
            }
        }
    }
    
    func testInput() {
        userIDTextField.text = "hoge"
        passwordTextField.text = "hogehoge"
        tokenTextField.text = "eb13de6e9b5613e77966597adcad99341399317b"
    }
    
    func setUserInfo() -> qiitaUserInfo {
        var info = qiitaUserInfo(userID: "", password: "", token: "")
        if let userID = self.userIDTextField.text,
           let password = self.passwordTextField.text,
           let token = self.tokenTextField.text {
            info.userID = userID
            info.password = password
            info.token = token
            return info
        }
        return info
    }
}
