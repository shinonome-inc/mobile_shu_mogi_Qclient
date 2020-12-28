//
//  RequestParameters.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/05.
//

import Foundation

class RequestParametersCreater {
    var dataType: DataType!
    private let baseUrl = "https://qiita.com/api/v2/"
    var url = ""
    var perPageNumber = 20
    var searchDict: [SearchOption: String]?
    var sortdict: [QueryOption: SortOption]?
    
    private var queryItems: [URLQueryItem]!
    init(dataType: DataType,
         pageNumber: Int?,
         searchDict: [SearchOption: String]?,
         sortdict: [QueryOption: SortOption]?) {
        self.dataType = dataType
        self.searchDict = searchDict
        self.sortdict = sortdict
        self.url = baseUrl + self.dataType.rawValue
        
    }
    
    //searchDict->String（エンコード済み）に変換
    //ex)[tag:Swift] -> tag%3ASwift
    func dictToStr(searcDict: [SearchOption: String]) -> String {
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
    
    func assembleItemURL(pageNumber: Int) -> String {
        //データタイプが"記事"でないと警告が出る
        if self.dataType != DataType.article {
            print("ERROR: get a data type that is different from the specified data type.")
        }

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
        } 
        //↑searchbar検索用
        
        if let url = urlComponents.string {
            self.url = url
        } else {
            print("There was an error converting the URL Component to a String.")
            return self.url
        }
        
        return self.url
    }
    
    func assembleTagURL(pageNumber: Int) -> String {
        //データタイプが"タグ"でないと警告が出る
        if self.dataType != DataType.tag {
            print("ERROR: get a data type that is different from the specified data type.")
        }
        //Sortが指定されていなかったら指定する
        guard self.sortdict != nil else {
            return self.url
        }
        //queryItemsの設定
        self.queryItems = [
            URLQueryItem(name: QueryOption.page.rawValue, value: String(pageNumber)),
            URLQueryItem(name: QueryOption.perPage.rawValue, value: String(perPageNumber))
        ]
        //sortオプションがあればsortオプションを追加する
        if let sortdict = self.sortdict {
            if let sortKey = sortdict.keys.first,
               let sortValue = sortdict.values.first {
                self.queryItems.append(URLQueryItem(name: sortKey.rawValue, value: sortValue.rawValue))
            }
        }
        guard var urlComponents = URLComponents(string: self.url) else {
            return self.url
        }
        urlComponents.queryItems = self.queryItems
        
        if let url = urlComponents.string {
            self.url = url
        } else {
            print("There was an error converting the URL Component to a String.")
            return self.url
        }
        
        return self.url
    }
    
    func assembleAuthURL() -> String {
        if self.dataType != DataType.auth {
            print("ERROR: get a data type that is different from the specified data type.")
        }
        return self.url
    }
}
