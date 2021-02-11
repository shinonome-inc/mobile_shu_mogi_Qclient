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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        loadWebView()
        let getToken = RequestParametersCreater(dataType: .getToken).assembleGetTokenURL()
        print("test getToken: \(getToken)")
    }
    
    func loadWebView() {
        let oAuthURL = RequestParametersCreater(dataType: .oauth).assembleOAuthURL()
        print("test oauth: \(oAuthURL)")
        guard let url = URL(string: oAuthURL) else { return }
        let urlRequest = URLRequest(url: url)
        
        webview.load(urlRequest)
    }
}

extension OAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let redirectURL = navigationAction.request.url,
           let code = redirectURL.getCode() {
            print("code \(code)")
            
        }
        
        decisionHandler(.allow)
        
    }
}
