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
        loadWebView()
        let getToken = RequestParametersCreater(dataType: .getToken).assembleGetTokenURL()
        print("test getToken: \(getToken)")
    }
    
    func loadWebView() {
        let oAuthURL = RequestParametersCreater(dataType: .oauth).assembleOAuthURL()
        guard let url = URL(string: oAuthURL) else { return }
        let urlRequest = URLRequest(url: url)
        webview.load(urlRequest)
    }
}
