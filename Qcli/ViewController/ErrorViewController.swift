//
//  ErrorViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/10.
//

import UIKit

class ErrorViewController: UIViewController {
    
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var backLoginVCButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    var qiitaError: QiitaError?
    var errorDelegate: ErrorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let qiitaError = qiitaError {
            setConfig(qiitaError: qiitaError)
        }
    }
    
    func setConfig(qiitaError: QiitaError) {
        errorMessageLabel.text = qiitaError.errorMessage
        switch qiitaError {
        case .rateLimitExceededError:
            reloadButton.isHidden = false
        case .unauthorizedError:
            reloadButton.isHidden = true
        case .connectionError:
            reloadButton.isHidden = false
        }
    }
    
    func checkSafeArea(viewController: UIViewController) {
        guard let tabBarController = viewController.tabBarController else { return }
        guard let navBarController = viewController.navigationController else { return }
        let tabBarHeight = tabBarController.tabBar.frame.height
        let navBarHeight = navBarController.navigationBar.frame.height
        let height = viewController.view.frame.height - tabBarHeight - navBarHeight
        self.view.frame = CGRect(x: 0.0,
                                 y: navBarHeight,
                                 width: viewController.view.frame.width,
                                 height: height)
    }
    
    @IBAction func backToLoginButtonTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        if let errorDelegate = errorDelegate {
            errorDelegate.backToLoginViewController()
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        self.view.removeFromSuperview()
        if let errorDelegate = errorDelegate {
            errorDelegate.reload()
        }
    }
    
}
