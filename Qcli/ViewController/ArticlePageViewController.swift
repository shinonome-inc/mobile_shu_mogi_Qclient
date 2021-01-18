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
    var articleData: ArticleData?
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webViewLoad(articleData: articleData)
    }
    
    func webViewLoad(articleData: ArticleData?) {
        if let articleData = articleData,
           let url = URL(string: articleData.articleURL) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
}

extension ArticlePageViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError: Error) {
        segueErrorViewController(qiitaError: .connectionError)
    }

}

extension ArticlePageViewController: ErrorDelegate {
    func segueErrorViewController(qiitaError: QiitaError) {
        //Prepare ErrorViewController
        guard let storyboard = self.storyboard else { abort() }
        let identifier = ViewControllerIdentifier.error.rawValue
        let errorViewController = storyboard.instantiateViewController(identifier: identifier) as! ErrorViewController
        errorViewController.errorDelegate = self
        //Send property, Segue
        errorViewController.qiitaError = qiitaError
        self.present(errorViewController, animated: true, completion: nil)
    }
    
    func backToLoginViewController() {
        let identifier = ViewControllerIdentifier.login.rawValue
        if let storyboard = self.storyboard,
           let navigationController = self.navigationController {
            let loginViewController = storyboard.instantiateViewController(identifier: identifier) as! LoginViewController
            navigationController.pushViewController(loginViewController, animated: true)
        }
    }
    
    func reload() {
        webViewLoad(articleData: articleData)
    }
    
    
}
