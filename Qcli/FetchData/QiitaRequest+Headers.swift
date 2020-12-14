//
//  AlamofireSession.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/12.
//

import Foundation
import Alamofire

class QiitaRequest {
    var headers: HTTPHeaders? = nil
    func request(url: URL) -> DataRequest {
        let dataRequest = AF.request(url, headers: self.headers)
        return dataRequest
    }
}

