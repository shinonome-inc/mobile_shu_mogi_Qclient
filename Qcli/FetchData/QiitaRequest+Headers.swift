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
        if self.isNotAuth {
            self.setHeaders()
        }            
        
        if let headers = self.headers {
            print("Headers 👉 \(String(describing: headers))")
        }
        let dataRequest = AF.request(url, headers: self.headers)
        return dataRequest
    }
    
    func setHeaders() {
        let keyhchain = KeyChain()
        if let token = keyhchain.get() {
            
            self.headers = [
                "Authorization": "Bearer " + token
            ]            
            
        } else {
            self.headers = nil
        }
    }
}

