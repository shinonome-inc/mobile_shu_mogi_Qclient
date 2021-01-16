//
//  ErrorDelegate.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/15.
//

import Foundation

protocol ErrorDelegate: NSObjectProtocol {
    var errorViewController: ErrorViewController { get }
    func segueErrorViewController(qiitaError: QiitaError)
    func backToLoginViewController()
}

