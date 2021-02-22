//
//  MyNavigationController.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/22.
//

import UIKit

class MyNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarColor()
        setBackButton()
    }
    
    func setNavigationBarColor() {
        navigationBar.backgroundColor = Palette.barTintColor
        navigationBar.tintColor = Palette.backButtonColor
    }
    
    func setBackButton() {
        if #available(iOS 14.0, *) {
          navigationItem.backButtonDisplayMode = .minimal
        } else {
          navigationItem.backButtonTitle = " "
        }
    }
}
