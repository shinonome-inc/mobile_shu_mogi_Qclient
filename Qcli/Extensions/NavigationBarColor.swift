//
//  NavigationBarColor.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/15.
//

import UIKit
extension UINavigationController {
    var isDarkMode: Bool {
        if #available(iOS 13, *), UITraitCollection.current.userInterfaceStyle == .dark {
            return true
        }
        return false
    }
    
    func setNavigationBarColor() {
        if isDarkMode {
            self.navigationBar.barTintColor = .black
        } else {
            self.navigationBar.barTintColor = .white
        }
        
    }
}
