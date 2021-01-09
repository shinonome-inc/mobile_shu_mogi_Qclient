//
//  FetchAirticleData.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/05.
//

import Foundation

class AirticleDataNetworkService {
    var perPageNumber = 20
    var searchDict: [SearchOption: String]?
    var pageNumber: Int
    var sortdict: [QueryOption: SortOption]?
    
    init(searchDict: [SearchOption: String]?) {
        pageNumber = 1
        self.searchDict = searchDict
    }
    
    func fetch(success: @escaping ((_ result: [AirticleModel]?) -> Void),
               failure: @escaping ((_ error: NSError?) -> Void)) {
        //↓URLの設定
        let reqParamModel = RequestParametersCreater(
            dataType: .article,
            pageNumber: pageNumber,
            searchDict: searchDict,
            sortdict: nil)
        let urlText = reqParamModel.assembleItemURL(pageNumber: pageNumber)
        guard let url = URL(string: urlText) else { return }
        //↑URLの設定
        
        let qiitaRequest = QiitaRequest()
        //↓QittaRequestのメソッドrequestは引数にheadersを設置しなくてもリクエスト時にヘッダー情報を組み込むようにしている
        qiitaRequest.request(url: url).response { response in
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
