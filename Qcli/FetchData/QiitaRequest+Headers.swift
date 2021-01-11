//
//  AlamofireSession.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/12.
//

import Foundation
import Alamofire

class QiitaRequest {
    var isNotAuth = true
    var headers: HTTPHeaders? = nil
    func request(url: URL) -> DataRequest {
        print("Request 👉 \(url)")
        if isNotAuth && isLogined() {
            setHeaders()
        } 
        
        if let headers = headers {
            print("Headers 👉 \(String(describing: headers))")
        } else {
            print("Headers 👉 None")
        }
        let dataRequest = AF.request(url, headers: headers)
        return dataRequest
    }
    
    func setHeaders() {
        let keyhchain = KeyChain()
        if let token = keyhchain.get() {
            
            headers = [
                "Authorization": "Bearer " + token
            ]            
            
        } else {
            headers = nil
        }
    }
    
    func isLogined() -> Bool {
        var value = false
        value = UserDefaults.standard.bool(forKey: "isLogined")
        return value
    }
}

