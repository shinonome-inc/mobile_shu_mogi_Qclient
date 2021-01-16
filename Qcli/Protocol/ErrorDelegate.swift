//
//  ErrorDelegate.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/15.
//

import Foundation

protocol ErrorDelegate: NSObjectProtocol {
    func segueErrorViewController()
    func backToLoginViewController()
}

