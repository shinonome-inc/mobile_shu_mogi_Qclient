//
//  ArticlePageViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/15.
//

import UIKit
import WebKit

class ArticlePageViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var urlStr: String!
    var articleData: ArticleData!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let articleData = self.articleData {
            let url = URL(string: articleData.articleURL)
            if let url = url {
                let urlRequest = URLRequest(url: url)
                webView.load(urlRequest)
            }
        }
    }
    
}
