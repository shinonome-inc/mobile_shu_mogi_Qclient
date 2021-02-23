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
    }
    
    func setConfig() {
        setNavigationBarColor()
        hideBackButtonTitle()
    }
    
    func setNavigationBarColor() {
        navigationBar.backgroundColor = Palette.barTintColor
        navigationBar.tintColor = Palette.backButtonColor
    }
    
    func hideBackButtonTitle() {
        navigationBar.topItem?.backButtonTitle = " "
    }
}
