//
//  ErrorView.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/23.
//

import Foundation
import UIKit

class ErrorView: UIView {
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var backLoginVCButton: UIButton!
    @IBOutlet weak var errorTypeLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    var qiitaError: QiitaError?
    var errorDelegate: ErrorDelegate?
    
    static func make() -> ErrorView {
        let view = UINib(nibName: "ErrorView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)
            .first as! ErrorView
        return view
    }
    
    @IBAction func backToLoginButtonTapped(_ sender: Any) {
        self.removeFromSuperview()
        if let errorDelegate = errorDelegate {
            errorDelegate.backToLoginViewController()
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        self.removeFromSuperview()
        if let errorDelegate = errorDelegate {
            errorDelegate.reload()
        }
    }
    
    func checkSafeArea(viewController: UIViewController) {
        guard let tabBarController = viewController.tabBarController else { return }
        guard let navBarController = viewController.navigationController else { return }
        let tabBarHeight = tabBarController.tabBar.frame.height
        let navBarHeight = navBarController.navigationBar.frame.height
        let height = viewController.view.frame.height - tabBarHeight - navBarHeight
        frame = CGRect(x: 0.0,
                       y: navBarHeight,
                       width: viewController.view.frame.width,
                       height: height)
    }
    
    func setConfig() {
        
        guard let qiitaError = qiitaError else { return }
        errorTypeLabel.text = qiitaError.errorType
        errorMessageLabel.text = qiitaError.errorMessage
        
        switch qiitaError {
        case .rateLimitExceededError:
            reloadButton.isHidden = false
        case .unauthorizedError:
            reloadButton.isHidden = true
        case .connectionError:
            reloadButton.isHidden = false
        case .unexpectedError:
            reloadButton.isHidden = true
        }
    }
}
