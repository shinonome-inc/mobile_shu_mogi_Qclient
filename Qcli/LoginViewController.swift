//
//  LoginOAuthViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/09.
//

import UIKit
import Alamofire
import SwiftyJSON

struct qiitaUserInfo: Codable {
    var token: String
}

class LoginViewController: UIViewController {
    
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
//        if let _ = UserDefaults.standard.object(forKey: "isLogined") {
//            performSegue(withIdentifier: "toTabBarController", sender: nil)
//        }
        
    }
    
    @IBAction func login(_ sender: Any) {
        print("login button tapped")
        let userInfo = self.setUserInfo()
        qiitaAuthentication(info: userInfo)
    }
    
    func setLayout() {
        tokenTextField.layer.cornerRadius = cornerRadiusValue
        loginButton.layer.cornerRadius = cornerRadiusValue
        notLoginButton.layer.cornerRadius = cornerRadiusValue
    }
    
    //ユーザー情報を入力して正しいかどうか判定し、正しければ画面遷移
    func qiitaAuthentication(info: qiitaUserInfo) {
        print("qiitaAuthentication呼ばれました")
        let url: String = "https://qiita.com/api/v2/authenticated_user"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + info.token
        ]
        print(headers)
        AF.request(url, method: .get, headers: headers).responseJSON{ response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                //jsonファイルの中にidの項目があれば認証成功とする
                if json["id"].string != nil {
                    print("リクエスト成功")
                    self.registerIsLogined(isLogined: true)
                    //userInfoに値をUserDefaultに受け渡す
                    self.saveUserDefault(userInfo: info)
                    //認証成功した場合は次の画面に遷移する
                    self.performSegue(withIdentifier: "toTabBarController", sender: nil)
                    
                } else {
                    //jsonファイルの中にidの項目がなければ認証失敗とする
                    self.registerIsLogined(isLogined: false)
                    //self.displayMyAlertMessage(userMessage: "リクエストは送信できましたが、無効なトークンです。")
                    print("リクエストは送信できましたが、無効なトークンです。")
                }
            case .failure:
                self.registerIsLogined(isLogined: false)
                self.displayMyAlertMessage(userMessage: "リクエスト送信できませんでした。")
                print(response.result)
                
            }
        }
       
    }
    
    func testInput() {
        tokenTextField.text = "019d7212b6a078db151f8eae4c6948dfe9f71232"
    }
    
    func setUserInfo() -> qiitaUserInfo {
        var info = qiitaUserInfo(token: "")
        if let token = self.tokenTextField.text {
            info.token = token
            return info
        }
        return info
    }
    
    func displayMyAlertMessage(userMessage: String) {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle:  UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler:nil)
        myAlert.addAction(okAction);
        self.present(myAlert,animated:true, completion:nil)
        
    }
    
    func registerIsLogined(isLogined: Bool) {
        let userDefault = UserDefaults.standard
        userDefault.set(isLogined, forKey: "isLogined")
    }
    
    func saveUserDefault(userInfo: qiitaUserInfo) {
        //userDefaultにユーザー情報を入れる
        let userDefault = UserDefaults.standard
        userDefault.set(try? PropertyListEncoder().encode([userInfo]), forKey: "userInfo")
    }
    
}
