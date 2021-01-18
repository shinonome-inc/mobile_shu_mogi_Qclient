//
//  File.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/17.
//

import Foundation

class AuthDataNetworkService {
    var token: String?
    var errorDelegate: ErrorDelegate?
    
    init(token: String?) {
        self.token = token
    }
    
    func fetch(success: @escaping (UserModel) -> (),
               failure: @escaping (NSError) -> ()) {
        //↓URLの設定
        let reqParamCreater = RequestParametersCreater(
            dataType: .auth,
            pageNumber: nil,
            searchDict: nil,
            sortdict: nil)
        let urlText = reqParamCreater.assembleAuthURL()
        guard let url = URL(string: urlText) else { return }
        //↑URLの設定
        let qiitaRequest = QiitaRequest()
        qiitaRequest.isNotAuth = false
        if let token = token {
            qiitaRequest.headers = [
                "Authorization": "Bearer " + token
            ]
        }
        
        qiitaRequest.request(url: url).response { response in
            guard let data = response.data else {
                return
            }
            //取得したデータを格納
            guard let exportData = try? JSONDecoder().decode(UserModel.self, from: data) else {
                print("An error occurred during decoding.")
                if let exceptionData = try? JSONDecoder().decode(ErrorModel.self, from: data) {
                    //1日のリクエスト数が上限に達した場合
                    if let message = exceptionData.message,
                       let type = exceptionData.type {
                        print("message: \(message), type: \(type)")
                        if let errorDelegate = self.errorDelegate {
                            errorDelegate.segueErrorViewController(qiitaError: .rateLimitExceededError)
                        }
                    }
                } else {
                    print("Failed to get error message.")
                }
                if let error = response.error {
                    failure(error as NSError)
                }
                return
            }
            success(exportData)
        }
        
       
    }
}
