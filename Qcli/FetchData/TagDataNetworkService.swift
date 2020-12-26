//
//  TagDataNetworkService.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/16.
//

import Foundation

class TagDataNetworkService {
    var perPageNumber: Int?
    var searchDict: [SearchOption: String]?
    var pageNumber: Int
    var sortdict: [QueryOption:SortOption]?
    
    init(sortDict: [QueryOption:SortOption]?) {
        self.pageNumber = 1
        self.perPageNumber = 20
        self.searchDict = nil
        self.sortdict = sortDict
    }
    
    func fetch(success: @escaping ((_ result: [TagModel]?) -> Void),
               failure: @escaping ((_ error: NSError?) -> Void)) {
        //↓URLの設定
        let reqParamModel = RequestParametersCreater(
            dataType: .tag,
            pageNumber: self.pageNumber,
            perPageNumber: self.perPageNumber,
            searchDict: self.searchDict,
            sortdict: self.sortdict)
        let urlText = reqParamModel.assembleTagURL(pageNumber: pageNumber)
        guard let url = URL(string: urlText) else { return }
        //↑URLの設定
        let qiitaRequest = QiitaRequest()

        //↓QittaRequestのメソッドrequestは引数にheadersを設置しなくてもリクエスト時にヘッダー情報を組み込むようにしている
        qiitaRequest.request(url: url).response { response in
            guard let data = response.data else {
                return
            }
            //取得したデータを格納
            guard let exportData = try? JSONDecoder().decode([TagModel].self, from: data) else {
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
