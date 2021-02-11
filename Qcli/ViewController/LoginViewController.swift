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
    let userInfoKeychain = KeyChain()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.setUpNotificationForTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //2回目のログインだとログインをスキップさせる
        //        if let _ = UserDefaults.standard.object(forKey: "isLogined") {
        //            performSegue(withIdentifier: SegueId.fromLoginToTabBarController.rawValue, sender: nil)
        //        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromLoginToOAuthController.rawValue) {
            if let destinationNavigationController = segue.destination as? UINavigationController,
               let oAuthViewController = destinationNavigationController.topViewController as? OAuthViewController {
                oAuthViewController.delegate = self
            }
            
        }
    }
    
    @IBAction func login(_ sender: Any) {
        performSegue(withIdentifier: SegueId.fromLoginToOAuthController.rawValue, sender: nil)
    }
    
    @IBAction func useAppWithoutLogin(_ sender: Any) {
        self.userInfoKeychain.remove()
        UserDefaults.standard.set(false, forKey: "isLogined")
        self.performSegue(withIdentifier: SegueId.fromLoginToTabBarController.rawValue, sender: nil)
    }
    
}

extension LoginViewController: OAuthViewControllerDelegate {
    func oAuthViewControllerDidFinish() {
        performSegue(withIdentifier: SegueId.fromLoginToTabBarController.rawValue, sender: nil)
    }    
}
