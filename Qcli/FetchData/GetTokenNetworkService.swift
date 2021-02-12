//
//  GetTokenNetworkService.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/11.
//

import Foundation

class GetTokenNetworkService {
    
    func accessToken(code: String,
                     success: @escaping () -> (),
                     failure: @escaping () -> ()) {
        
        let getTokenURL = RequestParametersCreater(dataType: .getToken).assembleGetTokenURL()
        guard let url = URL(string: getTokenURL) else { return }
        
        let qiitaRequest = QiitaRequest()
        qiitaRequest.method = .post
        qiitaRequest.parameters = [
            "client_id": AuthorizeKey.clientId.rawValue,
            "client_secret": AuthorizeKey.clientSecret.rawValue,
            "code": code
        ]
        qiitaRequest.headers = [
            "ACCEPT": "application/json"
        ]
        
        qiitaRequest.request(url: url).response { response in
            if let data = response.data,
               let accessInfoModel = try? JSONDecoder().decode(AccessInfoModel.self, from: data) {
                print(accessInfoModel)
            } else {
                print("accessInfoModel デコードできず")
            }
            guard let data = response.data,
                  let accessInfoModel = try? JSONDecoder().decode(AccessInfoModel.self, from: data),
                  let token = accessInfoModel.token else {
                UserDefaults.standard.set(false, forKey: "isLogined")
                failure()
                return
            }
            let keychain = KeyChain()
            keychain.set(token: token)
            success()
        }
    }
}
