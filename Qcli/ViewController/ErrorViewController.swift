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
            backLoginVCButton.setTitle("戻る", for: .normal)
            reloadButton.isHidden = true
        case .connectionError:
            reloadButton.isHidden = false
        }
    }
    
    @IBAction func backToLoginButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if let errorDelegate = errorDelegate {
            errorDelegate.backToLoginViewController()
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if let errorDelegate = errorDelegate {
            errorDelegate.reload()
        }
    }
    
}
