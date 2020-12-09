//
//  RequestParameters.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/05.
//

import Foundation

class RequestParametersModel {
    var dataType: DataType!
    private let baseUrl = "https://qiita.com/api/v2/"
    var url = ""
    var pageNumber: Int?
    var perPageNumber: Int?
    var searchDict: [SearchOption:String]?
    var sortdict: [QueryOption:SortOption]?
    var userInfo: qiitaUserInfo?
    private var queryItems: [URLQueryItem]!
    init(dataType: DataType,
         pageNumber: Int?,
         perPageNumber: Int?,
         searchDict: [SearchOption:String]?,
         sortdict: [QueryOption:SortOption]?,
         userInfo: qiitaUserInfo?) {
        self.dataType = dataType
        self.pageNumber = pageNumber
        self.perPageNumber = perPageNumber
        self.searchDict = searchDict
        self.sortdict = sortdict
        self.userInfo = userInfo
        self.url = baseUrl + self.dataType.rawValue
    }
    
    //searchDict->String（エンコード済み）に変換
    //ex)[tag:Swift] -> tag%3ASwift
    func dictToStr(searcDict: [SearchOption:String]) -> String {
        var export = ""
        var count = 1
        guard let searchDict = self.searchDict else { return "" }
        let maxCount = searchDict.count
        for (key, value) in searchDict {
            let searchQuery = key.rawValue + ":" + value
            export += searchQuery
            if count < maxCount {
                export += "+"
                count += 1
            }
        }
        print("🔍　Search Query　👉 \(export)")
        return export
    }
    
    func assembleItemURL(pageNumber: Int?) -> String {
        //データタイプが"記事"でないと警告が出る
        if self.dataType != DataType.article {
            print("ERROR: get a data type that is different from the specified data type.")
        }
        //引数をself.pageNumberを代入
        if let pageNumber = pageNumber {
            self.pageNumber = pageNumber
        } else {
            print("❌ pageNumber is not the correct type.")
        }
        //unwraping pageNumber, perPageNumber
        guard let pageNumber = self.pageNumber else { return self.url }
        guard let perPageNumber = self.perPageNumber else { return self.url }
        self.queryItems = [
            URLQueryItem(name: QueryOption.page.rawValue, value: String(pageNumber)),
            URLQueryItem(name: QueryOption.perPage.rawValue, value: String(perPageNumber))
        ]
        guard var urlComponents = URLComponents(string: self.url) else {
            return self.url
        }
        urlComponents.queryItems = queryItems
        //↓searchbar検索用
        if let searchDict = self.searchDict {
            let toStr = dictToStr(searcDict: searchDict)
            let searchOptionQuery = URLQueryItem(name: QueryOption.query.rawValue, value: toStr)
            urlComponents.queryItems?.append(searchOptionQuery)
        } else {
            print("⚠️ It does not use queries other than page specification.")
        }
        //↑searchbar検索用
        
        if let url = urlComponents.string {
            self.url = url
        } else {
            print("There was an error converting the URL Component to a String.")
            return self.url
        }
        
        print("Request 👉 \(self.url)")
        
        return self.url
    }
}
