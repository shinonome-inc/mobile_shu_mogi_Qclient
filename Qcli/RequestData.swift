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

class RequestData {
    var userInfo: qiitaUserInfo!
    //var headers: HTTPHeaders!
    var urlComponents: URLComponents!
    let dataType: DataType!
    var headers: HTTPHeaders!
    var queryItems: [URLQueryItem]!
    
    init(dataType: DataType, queryItems: [URLQueryItem]) {
        self.userInfo = nil
        self.dataType = dataType
        self.headers = nil
        self.queryItems = queryItems
    }
    
    init(dataType: DataType, headers: HTTPHeaders, queryItems: [URLQueryItem]) {
        self.userInfo = nil
        self.dataType = dataType
        self.headers = headers
        self.queryItems = queryItems
    }
    
    init(dataType: DataType ,userInfo: qiitaUserInfo, headers: HTTPHeaders, queryItems: [URLQueryItem]) {
        self.userInfo = userInfo
        self.dataType = dataType
        self.headers = headers
        self.queryItems = queryItems
    }
    
    //認証用
    init(dataType: DataType ,userInfo: qiitaUserInfo) {
        self.userInfo = userInfo
        self.dataType = dataType
        self.headers = nil
        self.queryItems = nil
    }
    
    func registerIsLogined(isLogined: Bool) {
        let userDefault = UserDefaults.standard
        userDefault.set(isLogined, forKey: "isLogined")
    }
    
    func saveUserDefault(userInfo: qiitaUserInfo) {
        //userDefaultにユーザー情報を入れる
        let userDefault = UserDefaults.standard
        userDefault.set(try? PropertyListEncoder().encode([userInfo]), forKey: "userInfo")
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
        
        if let queryItems = self.queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            print("There was an error converting the URL Component to a URL.")
            return
        }
        //↑ 検索クエリ追加
        
        print("Request with \(url)")
        
        //alamofireでデータをリクエスト
        AF.request(url).response { respose in
            guard let data = respose.data else {
                return
            }
            //取得したデータを格納
            guard let exportData = try? JSONDecoder().decode([AirticleModel].self, from: data) else {
                print("An error occurred during decoding.")
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
        
        print("Request with \(url)")
        
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
        
        if let queryItems = self.queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            print("There was an error converting the URL Component to a URL.")
            return
        }
        //↑ 検索クエリ追加
        
        print("Request with \(url)")
        
        //alamofireでデータをリクエスト
        AF.request(url).response { respose in
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
                    print("Saved user information in UserDefaults.")
                    self.registerIsLogined(isLogined: true)
                    print("Login will be skipped from the second time onwards.")
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


