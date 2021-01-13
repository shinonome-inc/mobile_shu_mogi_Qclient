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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setConfig(qiitaError: QiitaError) {
        errorMessageLabel.text = qiitaError.errorMessage
        switch qiitaError {
        case .rateLimitExceededError:
            reloadButton.isHidden = false
        case .unauthorizedError:
            backLoginVCButton.setTitle("戻る", for: .normal)
            reloadButton.isHidden = true
        case .connectionError:
            reloadButton.isHidden = false
        }
    }
}
