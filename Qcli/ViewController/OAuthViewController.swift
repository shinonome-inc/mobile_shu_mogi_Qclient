//
//  OAuthViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/11.
//

import UIKit
import WebKit

class OAuthViewController: UIViewController {
    @IBOutlet weak var webview: WKWebView!
    var delegate: OAuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        loadWebView()
    }
    
    func loadWebView() {
        let oAuthURL = RequestParametersCreater(dataType: .oauth).assembleOAuthURL()
        print("LoadView 👉\(oAuthURL)")
        guard let url = URL(string: oAuthURL) else { return }
        let urlRequest = URLRequest(url: url)
        webview.load(urlRequest)
    }
    //リクエスト失敗した時用のアラート
    func displayMyAlertMessage(userMessage: String) {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle:  UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler:nil)
        myAlert.addAction(okAction);
        present(myAlert,animated:true, completion:nil)
    }
}

extension OAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let redirectURL = navigationAction.request.url,
           let code = redirectURL.getCode() {
            let getToken = GetTokenNetworkService()
            getToken.accessToken(code: code,
                                 success: {
                                    self.dismiss(animated: true, completion: nil)
                                    if let delegate = self.delegate {
                                        delegate.oAuthViewControllerDidFinish()
                                    }
                                 },
                                 failure: {
                                    self.displayMyAlertMessage(userMessage: "トークン取得に失敗しました。")
                                 })
            
        }
        
        decisionHandler(.allow)
        
    }
}
