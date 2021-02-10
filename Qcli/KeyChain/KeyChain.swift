//
//  KeyChain.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/17.
//

import KeychainAccess

enum KeychainValue: String {
    case serviceName = "Qiita"
    case token = "token"
}
class KeyChain {
    var tokenInfo: Keychain!
    var errorDelegate: ErrorDelegate?
    init() {
        tokenInfo = Keychain(service: KeychainValue.serviceName.rawValue)
    }
    
    func set(token: String) {
        tokenInfo[KeychainValue.token.rawValue] = token
        print("👍 Success: Save your token in keychain")
        print("🗝 Your token: \(token)")
        UserDefaults.standard.set(true, forKey: "isLogined")
    }
    
    func get() -> String? {
        if let exportStr = tokenInfo[KeychainValue.token.rawValue] {
            return exportStr
        } else {
            print("⚠️ ERROR: Token information does not exist.")
            UserDefaults.standard.set(false, forKey: "isLogined")
            if let delegate = errorDelegate {
                delegate.segueErrorViewController(qiitaError: .unauthorizedError)
            }
            return nil
        }
    }
    
    func remove() {
        do {
            try tokenInfo.remove(KeychainValue.token.rawValue)
            UserDefaults.standard.set(false, forKey: "isLogined")
            print("👍 Success: Delete your token in keychain")
        } catch let error {
            print("⚠️ ERROR: Could not delete token.")
            print("error: \(error)")
        }
        
    }
}
