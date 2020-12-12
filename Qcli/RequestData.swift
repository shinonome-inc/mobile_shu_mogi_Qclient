//
//  RequestData.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/20.
//

import Foundation
import Alamofire

enum DataType: String {
    case article = "items"
    case user = "users"
    case tag = "tags"
    case auth = "authenticated_user"
}

enum SearchOption: String, CaseIterable {
    case title = "title"
    case tag = "tag"
    case body = "body"
    case user = "user"
}

class RequestData {
    var userInfo: QiitaUserInfo!
    //var headers: HTTPHeaders!
    var urlComponents: URLComponents!
    var dataType: DataType!
    var queryItems: [URLQueryItem]!
    //qiitaのURL…&query=(searchOption):(String)
    var searchDict: [SearchOption:String]!
    var pageNumber: Int!
    var perPageNumber: Int!
    //tagデータ並び替えのための値
    var sortKey: QueryOption!
    var sortValue: SortOption!
    let testData = TestData()
    //AFデータリクエスト
    var AFrequest: DataRequest!
    
        
    //認証用 -> userInfo:必要, dataType:必要, pageNumber&perPageNumber:不要 searchDict:不要
    init(dataType: DataType ,userInfo: QiitaUserInfo) {
        self.userInfo = userInfo
        self.dataType = dataType
        self.queryItems = nil
        self.searchDict = nil
    }
    //検索なし -> userInfo:不要, dataType:必要, pageNumber&perPageNumber:必要 searchDict:不要
    init(dataType: DataType, pageNumber: Int, perPageNumber: Int) {
        self.userInfo = nil
        self.dataType = dataType
        self.pageNumber = pageNumber
        self.perPageNumber = perPageNumber
        self.searchDict = nil
    }
    //検索なし -> userInfo:不要, dataType:必要, pageNumber&perPageNumber:必要 searchDict:不要
    init(dataType: DataType, pageNumber: Int, perPageNumber: Int, userInfo: QiitaUserInfo) {
        self.userInfo = userInfo
        self.dataType = dataType
        self.pageNumber = pageNumber
        self.perPageNumber = perPageNumber
        self.searchDict = nil
    }
    //検索あり -> userInfo:不要, dataType:必要, pageNumber&perPageNumber:必要 searchDict:必要
    init(dataType: DataType, pageNumber: Int, perPageNumber: Int, searchDict: [SearchOption:String]) {
        self.userInfo = nil
        self.dataType = dataType
        self.pageNumber = pageNumber
        self.perPageNumber = perPageNumber
        self.searchDict = searchDict
    }
    
    //検索あり, ログインしている -> userInfo:必要, dataType:必要, pageNumber&perPageNumber:必要 searchDict:必要
    init(dataType: DataType, pageNumber: Int, perPageNumber: Int, searchDict: [SearchOption:String], userInfo: QiitaUserInfo) {
        self.userInfo = userInfo
        self.dataType = dataType
        self.pageNumber = pageNumber
        self.perPageNumber = perPageNumber
        self.searchDict = searchDict
    }
    
    
    //sortあり -> userInfo:不要, dataType:必要, pageNumber&perPageNumber:必要 searchDict:不要
    init(dataType: DataType, pageNumber: Int, perPageNumber: Int, sortdict: [QueryOption:SortOption]) {
        self.userInfo = nil
        self.dataType = dataType
        self.pageNumber = pageNumber
        self.perPageNumber = perPageNumber
        self.searchDict = nil
        if sortdict.count == 1 {
            self.sortKey = sortdict.keys.first
            self.sortValue = sortdict.values.first
        } else {
            print("⚠️ Caution: There is no or more SortDict.")
        }
    }
    
    //sortあり -> userInfo:不要, dataType:必要, pageNumber&perPageNumber:必要 searchDict:不要
    init(userInfo: QiitaUserInfo, dataType: DataType, pageNumber: Int, perPageNumber: Int, sortdict: [QueryOption:SortOption]) {
        self.userInfo = userInfo
        self.dataType = dataType
        self.pageNumber = pageNumber
        self.perPageNumber = perPageNumber
        self.searchDict = nil
        if sortdict.count == 1 {
            self.sortKey = sortdict.keys.first
            self.sortValue = sortdict.values.first
        } else {
            print("⚠️ Caution: There is no or more SortDict.")
        }
    }
    
    func registerIsLogined(isLogined: Bool) {
        let userDefault = UserDefaults.standard
        userDefault.set(isLogined, forKey: "isLogined")
    }
    
    func saveUserDefault(userInfo: QiitaUserInfo) {
        //userDefaultにユーザー情報を入れる
        let userDefault = UserDefaults.standard
        userDefault.set(try? PropertyListEncoder().encode([userInfo]), forKey: "userInfo")
    }
    
    func setURLQuerItems() {
        if let page = self.pageNumber,
           let perPage = self.perPageNumber {
            self.queryItems = [
                URLQueryItem(name: QueryOption.page.rawValue, value: String(page)),
                URLQueryItem(name: QueryOption.perPage.rawValue, value: String(perPage))
            ]
            if let sortKey = self.sortKey,
               let sortValue = self.sortValue {
                print("Added Sort Option　👉 \(sortKey.rawValue)=\(sortValue.rawValue)")
                let addURLQueryItem = URLQueryItem(name: sortKey.rawValue, value: sortValue.rawValue)
                self.queryItems.append(addURLQueryItem)
            }
        } else {
            print("⚠️　Request data withput queryItems.")
        }
    }
    
    //searchDict->String（エンコード済み）に変換
    //ex)[tag:Swift] -> tag%3ASwift
    func dictToStr(searcDict: [SearchOption:String]) -> String {
        var export = ""
        var count = 1
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
    
    func fetchAirtcleData(success: @escaping ((_ result: [AirticleModel]?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        //インスタンス化した時に指定したデータタイプと取得するデータタイプが違ければメソッドを抜け出す
        if self.dataType != DataType.article {
            print("ERROR: get a data type that is different from the specified data type.")
            return
        }
        
        
        let baseUrl = "https://qiita.com/api/v2/\(self.dataType.rawValue)"
        
        //↓ 検索クエリ追加
        guard var urlComponents = URLComponents(string: baseUrl) else {
            return
        }
        
        self.setURLQuerItems()
        
        if let queryItems = self.queryItems {
            urlComponents.queryItems = queryItems
            
        }
        //↑ 検索クエリ追加
        
        //↓searchbar検索用
        if let searchDict = self.searchDict {
            let toStr = dictToStr(searcDict: searchDict)
            let searchOptionQuery = URLQueryItem(name: QueryOption.query.rawValue, value: toStr)
            urlComponents.queryItems?.append(searchOptionQuery)
        } else {
            print("⚠️ It does not use queries other than page specification.")
        }
        //↑searchbar検索用
        
        guard let url = urlComponents.url else {
            print("There was an error converting the URL Component to a String.")
            return
        }
        
        print("Request 👉 \(url)")
        
        //インスタンス化した時にuserInfo(トークン情報)があればヘッダーをつける
        if let userInfo = self.userInfo {
            //headersに認証トークン格納
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + userInfo.token
            ]
            print("Headers 👉 \(headers)")
            self.AFrequest = AF.request(url,headers: headers)
        } else {
            self.AFrequest = AF.request(url)
        }
        
        //alamofireでデータをリクエスト
        self.AFrequest.response { respose in
            guard let data = respose.data else {
                return
            }
            
            //取得したデータを格納
            guard let exportData = try? JSONDecoder().decode([AirticleModel].self, from: data) else {
                print("An error occurred during decoding.")
                if let exceptionData = try? JSONDecoder().decode(ErrorModel.self, from: data) {
                    if let message = exceptionData.message,
                       let type = exceptionData.type {
                        print("message: \(message), type: \(type)")
                    }
                } else {
                    print("Failed to get error message.")
                }
                
                failure(respose.error as NSError?)
                return
            }
            success(exportData)
        }
    }
    
    func fetchUserData(success: @escaping ((_ result: [UserModel]?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        //インスタンス化した時に指定したデータタイプと取得するデータタイプが違ければメソッドを抜け出す
        if self.dataType != DataType.user {
            print("ERROR: get a data type that is different from the specified data type.")
            return
        }
        
        let baseUrl = "https://qiita.com/api/v2/\(self.dataType.rawValue)"
        
        //↓ 検索クエリ追加
        guard var urlComponents = URLComponents(string: baseUrl) else {
            return
        }
        
        if let queryItems = self.queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            print("There was an error converting the URL Component to a URL.")
            return
        }
        //↑ 検索クエリ追加
        
        print("Request 👉 \(url)")
        
        //alamofireでデータをリクエスト
        AF.request(url).response { respose in
            guard let data = respose.data else {
                return
            }
            print(data)
            //取得したデータを格納
            guard let exportData = try? JSONDecoder().decode([UserModel].self, from: data) else {
                print("An error occurred during decoding.")
                failure(respose.error as NSError?)
                return
            }
            success(exportData)
        }
    }
    
    func fetchTagData(success: @escaping ((_ result: [TagModel]?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        //インスタンス化した時に指定したデータタイプと取得するデータタイプが違ければメソッドを抜け出す
        if self.dataType != DataType.tag {
            print("ERROR: get a data type that is different from the specified data type.")
            return
        }
        
        let baseUrl = "https://qiita.com/api/v2/\(self.dataType.rawValue)"
        
        //↓ 検索クエリ追加
        guard var urlComponents = URLComponents(string: baseUrl) else {
            return
        }
        
        self.setURLQuerItems()
        
        if let queryItems = self.queryItems {
            urlComponents.queryItems = queryItems
        }
        
        //↑ 検索クエリ追加
        
        //↓searchbar検索用
        if let searchDict = self.searchDict {
            let toStr = dictToStr(searcDict: searchDict)
            let searchOptionQuery = URLQueryItem(name: QueryOption.query.rawValue, value: toStr)
            urlComponents.queryItems?.append(searchOptionQuery)
        } else {
            print("⚠️ It does not use queries other than page specification.")
        }
        //↑searchbar検索用
        
        guard let url = urlComponents.url else {
            print("There was an error converting the URL Component to a URL.")
            return
        }
        
        print("Request 👉 \(url)")
        
        //インスタンス化した時にuserInfo(トークン情報)があればヘッダーをつける
        if let userInfo = self.userInfo {
            //headersに認証トークン格納
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + userInfo.token
            ]
            print("Headers 👉 \(headers)")
            self.AFrequest = AF.request(url,headers: headers)
        } else {
            self.AFrequest = AF.request(url)
        }
        
        //alamofireでデータをリクエスト
        self.AFrequest.response { respose in
            guard let data = respose.data else {
                return
            }
            //取得したデータを格納
            guard let exportData = try? JSONDecoder().decode([TagModel].self, from: data) else {
                print("An error occurred during decoding.")
                failure(respose.error as NSError?)
                return
            }
            success(exportData)
        }
    }
    
    func isAuth(success: @escaping (UserModel) -> (),
                failure: @escaping (NSError) -> ()) {
        //インスタンス化した時に指定したデータタイプと取得するデータタイプが違ければメソッドを抜け出す
        if self.dataType != DataType.auth {
            print("ERROR: get a data type that is different from the specified data type.")
            return
        }
        
        //インスタンス化した時にuserInfo(トークン情報)がなければメソッドを抜け出す
        guard let userInfo = self.userInfo else {
            print("ERROR: userInfo has not been entered.")
            return
        }
        
        //headersに認証トークン格納
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + userInfo.token
        ]
        
        let baseUrl = "https://qiita.com/api/v2/\(self.dataType.rawValue)"
        let url = baseUrl
        
        print("Request 👉 \(url)")
        print("Headers 👉 \(headers)")
        
        //alamofireでデータをリクエスト
        AF.request(url, headers: headers).response { respose in
            switch respose.result {
            case .success(let data):
                guard let data = data else {
                    print("ERROR: The request was successful, but the data is nil.")
                    return
                }
                let decodingData = try? JSONDecoder().decode(UserModel.self, from: data)
                
                guard let exportData = decodingData else {
                    print("ERROR: The request was successful, but the data is nil.")
                    return
                }
                if exportData.id != nil {
                    self.saveUserDefault(userInfo: userInfo)
                    print("💾 Saved user information in UserDefaults.")
                    self.registerIsLogined(isLogined: true)
                    print("💫Login will be skipped from the second time onwards.")
                } else {
                    print("ERROR: Since the user id was nil, please check again if it is the correct token.")
                }
                
                success(exportData)
            case .failure(_):
                self.registerIsLogined(isLogined: false)
            }
        }
    }
}


