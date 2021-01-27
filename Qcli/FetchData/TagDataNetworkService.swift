//
//  TagDataNetworkService.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/16.
//

import Foundation

class TagDataNetworkService {
    var perPageNumber = 20
    var searchDict: [SearchOption: String]?
    var pageNumber: Int
    var sortdict: [QueryOption: SortOption]?
    var errorDelegate: ErrorDelegate?
    
    init(sortDict: [QueryOption: SortOption]?) {
        pageNumber = 1
        perPageNumber = 20
        searchDict = nil
        sortdict = sortDict
    }
    
    func fetch(success: @escaping ((_ result: [TagModel]?) -> Void),
               failure: @escaping ((_ error: NSError?) -> Void)) {
        //↓URLの設定
        let reqParamModel = RequestParametersCreater(
            dataType: .tag,
            pageNumber: pageNumber,
            searchDict: searchDict,
            sortdict: sortdict)
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
                        self.showErrorView(qiitaError: .rateLimitExceededError)
                    } else {
                        self.showErrorView(qiitaError: .unexpectedError)
                    }
                } else {
                    print("Failed to get error message.")
                    self.showErrorView(qiitaError: .unexpectedError)
                }
                
                failure(response.error as NSError?)
                return
            }
            success(exportData)
        }
    }
    
    func showErrorView(qiitaError: QiitaError) {
        if let errorDelegate = self.errorDelegate {
            errorDelegate.segueErrorViewController(qiitaError: qiitaError)
        } else {
            print("⚠️ ErrorDelegate: nil")
        }
    }
}
