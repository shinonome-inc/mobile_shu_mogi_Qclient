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
    var userType: UserListType?
    var userId: String?
    
    private var queryItems: [URLQueryItem]!
    init(dataType: DataType,
         pageNumber: Int? = nil,
         searchDict: [SearchOption: String]? = nil,
         sortdict: [QueryOption: SortOption]? = nil,
         userType: UserListType? = nil,
         userId: String? = nil) {
        self.dataType = dataType
        self.searchDict = searchDict
        self.sortdict = sortdict
        url = baseUrl + dataType.rawValue
        self.userType = userType
        self.userId = userId
    }
    
    //searchDict->String（エンコード済み）に変換
    //ex)[tag:Swift] -> tag%3ASwift
    func dictToStr(searcDict: [SearchOption: String]) -> String {
        var export = ""
        var count = 1
        guard let searchDict = searchDict else { return "" }
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
        if dataType != DataType.article {
            print("ERROR: get a data type that is different from the specified data type.")
        }

        queryItems = [
            URLQueryItem(name: QueryOption.page.rawValue, value: String(pageNumber)),
            URLQueryItem(name: QueryOption.perPage.rawValue, value: String(perPageNumber))
        ]
        guard var urlComponents = URLComponents(string: url) else {
            return url
        }
        urlComponents.queryItems = queryItems
        //↓searchbar検索用
        if let searchDict = searchDict {
            let toStr = dictToStr(searcDict: searchDict)
            let searchOptionQuery = URLQueryItem(name: QueryOption.query.rawValue, value: toStr)
            urlComponents.queryItems?.append(searchOptionQuery)
        } 
        //↑searchbar検索用
        
        if let url = urlComponents.string {
            self.url = url
        } else {
            print("There was an error converting the URL Component to a String.")
            return url
        }
        
        return url
    }
    
    func assembleTagURL(pageNumber: Int) -> String {
        //データタイプが"タグ"でないと警告が出る
        if dataType != DataType.tag {
            print("ERROR: get a data type that is different from the specified data type.")
        }
        //Sortが指定されていなかったら指定する
        guard sortdict != nil else {
            return url
        }
        //queryItemsの設定
        queryItems = [
            URLQueryItem(name: QueryOption.page.rawValue, value: String(pageNumber)),
            URLQueryItem(name: QueryOption.perPage.rawValue, value: String(perPageNumber))
        ]
        //sortオプションがあればsortオプションを追加する
        if let sortdict = sortdict {
            if let sortKey = sortdict.keys.first,
               let sortValue = sortdict.values.first {
                queryItems.append(URLQueryItem(name: sortKey.rawValue, value: sortValue.rawValue))
            }
        }
        guard var urlComponents = URLComponents(string: url) else {
            return url
        }
        urlComponents.queryItems = queryItems
        
        if let url = urlComponents.string {
            self.url = url
        } else {
            print("There was an error converting the URL Component to a String.")
            return url
        }
        
        return url
    }
    
    func assembleAuthURL() -> String {
        if dataType != DataType.auth {
            print("ERROR: get a data type that is different from the specified data type.")
        }
        return url
    }
    
    func assembleUserURL(pageNumber: Int) -> String {
        //データタイプが"タグ"でないと警告が出る
        if dataType != DataType.user {
            print("ERROR: get a data type that is different from the specified data type.")
        }
        //UserIdが入力チェック
        if let userId = userId {
            url += "/" + userId
        } else {
            print("⚠️ UserId = nil")
        }
        //UserType入力チェック
        if let userType = userType {
            url += "/" + userType.rawValue
        } else {
            print("⚠️ UseType = nil")
        }
        //queryItemsの設定
        queryItems = [
            URLQueryItem(name: QueryOption.page.rawValue, value: String(pageNumber)),
            URLQueryItem(name: QueryOption.perPage.rawValue, value: String(perPageNumber))
        ]
        guard var urlComponents = URLComponents(string: url) else {
            return url
        }
        urlComponents.queryItems = queryItems
        
        if let url = urlComponents.string {
            self.url = url
        } else {
            print("There was an error converting the URL Component to a String.")
            return url
        }
        
        return url
    }
    
    func assembleOAuthURL() -> String {
        let clientId = AuthorizeKey.clientId
        let scopekey = "scope"
        let scopeValue = "read_qiita+write_qiita"
        //データタイプが"OAuth"でないと警告が出る
        if dataType != DataType.oauth {
            print("ERROR: get a data type that is different from the specified data type.")
        }
        //queryItemsの設定
        queryItems = [
            URLQueryItem(name: QueryOption.clientId.rawValue, value: clientId.rawValue),
            URLQueryItem(name: scopekey, value: scopeValue)
        ]
        guard var urlComponents = URLComponents(string: url) else {
            return url
        }
        urlComponents.queryItems = queryItems
        
        if let url = urlComponents.string {
            self.url = url
        } else {
            print("There was an error converting the URL Component to a String.")
            return url
        }
        return url
    }
    
    func assembleGetTokenURL() -> String {
        return url
    }
}
