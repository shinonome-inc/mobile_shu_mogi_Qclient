//
//  FetchAirticleData.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/05.
//

import Foundation
import Alamofire
class AirticleDataNetworkService {
    var perPageNumber: Int?
    var searchDict: [SearchOption:String]?
    var pageNumber: Int
    var sortdict: [QueryOption:SortOption]?
    let headers: HTTPHeaders?
    
    init(searchDict: [SearchOption:String]?,
         userInfo: QiitaUserInfo?) {
        self.pageNumber = 1
        self.perPageNumber = 20
        self.searchDict = searchDict
        self.sortdict = nil
        if let userInfo = userInfo {
            self.headers = [
                "Authorization": "Bearer " + userInfo.token
            ]
            if let headers = self.headers {
                print("Headers 👉 \(headers)")
            }
        } else {
            self.headers = nil
        }
    }
    
    func fetch(success: @escaping ((_ result: [AirticleModel]?) -> Void),
               failure: @escaping ((_ error: NSError?) -> Void)) {
        let reqParamModel = RequestParametersModel(
            dataType: .article,
            pageNumber: self.pageNumber,
            perPageNumber: self.perPageNumber,
            searchDict: self.searchDict,
            sortdict: nil)
        let urlText = reqParamModel.assembleItemURL(pageNumber: pageNumber)
        guard let url = URL(string: urlText) else { return }
        AF.request(url, headers: self.headers).response { response in
            guard let data = response.data else {
                return
            }
            //取得したデータを格納
            guard let exportData = try? JSONDecoder().decode([AirticleModel].self, from: data) else {
                print("An error occurred during decoding.")
                if let exceptionData = try? JSONDecoder().decode(ErrorModel.self, from: data) {
                    //1日のリクエスト数が上限に達した場合
                    if let message = exceptionData.message,
                       let type = exceptionData.type {
                        print("message: \(message), type: \(type)")
                    }
                } else {
                    print("Failed to get error message.")
                }
                
                failure(response.error as NSError?)
                return
            }
            success(exportData)
        }
    }
}
