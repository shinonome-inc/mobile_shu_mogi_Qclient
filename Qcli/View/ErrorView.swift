//
//  ErrorView.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/23.
//

import Foundation
import UIKit

class ErrorView: UIView {
    var reloadButton: UIButton!
    var backLoginVCButton: UIButton!
    var errorMessageLabel: UILabel!
    var errorLabel: UILabel!
    var qiitaError: QiitaError?
    var errorDelegate: ErrorDelegate?
    var navigationController: UINavigationController?
    var tabbarController: UITabBarController?
    var viewController: UIViewController?
    
    func appear() {
        guard let viewController = getTopViewController() else { return }
        guard let navigationController = navigationController else { return }
        guard let tabbarController = tabbarController else { return }
        let navigationBarHeight = navigationController.navigationBar.frame.maxY
        let tabbarHeight = tabbarController.tabBar.frame.height
        let uiViewWidth = viewController.view.frame.width
        let uiViewHeight = viewController.view.frame.height
        self.backgroundColor = .white
        frame = CGRect(x: 0, y: navigationBarHeight, width: uiViewWidth, height: uiViewHeight - tabbarHeight - navigationBarHeight)
        viewController.view.addSubview(self)
        testButton()
    }
    
    func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController {
            var topViewController: UIViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            return topViewController
        } else {
            print("⚠️ getTopViewController: failed")
            return nil
        }
    }
    
    func getNavigationController(viewController: UIViewController) -> UINavigationController? {
        if let navigationController = viewController.navigationController {
            return navigationController
        } else {
            print("⚠️ getNavigationController: failed")
            return nil
        }
    }
    
    func setLayout() {
        showBackLoginVCButton()
        showReloadButton()        
        showErrorMessageLabel()
        showErrorLabel()
    }
    
    func showReloadButton() {
        reloadButton = UIButton()
        reloadButton.setTitle("RELOAD", for: .normal)
        reloadButton.addTarget(self, action: #selector(tappedReloadButton), for: .touchUpInside)
        self.addSubview(reloadButton)
        reloadButton.bottomAnchor.constraint(equalTo: backLoginVCButton.topAnchor, constant: 16.0).isActive = true
        reloadButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        reloadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 20.0).isActive = true
        reloadButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
    }
    
    func showBackLoginVCButton() {
        backLoginVCButton = UIButton()
        backLoginVCButton.setTitle("BACK TO LOGIN", for: .normal)
        backLoginVCButton.addTarget(self, action: #selector(tappedBackLoginVCButton), for: .touchUpInside)
        self.addSubview(backLoginVCButton)
        backLoginVCButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -36.0).isActive = true
        backLoginVCButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        backLoginVCButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 20.0).isActive = true
        backLoginVCButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
    }
    
    func showErrorLabel() {
        errorLabel = UILabel()
        errorLabel.text = "Error"
        self.addSubview(errorLabel)
        errorLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -60.0).isActive = true
        errorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: errorMessageLabel.topAnchor, constant: 12.0).isActive = true
    }
    
    func showErrorMessageLabel() {
        errorMessageLabel = UILabel()
        if let qiitaError = qiitaError {
            errorMessageLabel.text = qiitaError.errorMessage
        }
        errorMessageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        errorMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 20.0).isActive = true
    }
    
    @objc func tappedReloadButton() {
        
    }
    
    @objc func tappedBackLoginVCButton() {
        
    }
    
    func testButton() {
        let button = UIButton()
        button.backgroundColor = .black
        
        self.addSubview(button)
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0).isActive = true
        button.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0.0).isActive = true
    }
}
