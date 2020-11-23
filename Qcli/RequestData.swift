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
}

class RequestData {
    var token: String!
    //var headers: HTTPHeaders!
    var urlComponents: URLComponents!
    let dataType: DataType!
    var headers: HTTPHeaders!
    var queryItems: [URLQueryItem]!
    
    init(dataType: DataType, queryItems: [URLQueryItem]) {
        self.token = nil
        self.dataType = dataType
        self.headers = nil
        self.queryItems = queryItems
    }
    
    init(dataType: DataType, headers: HTTPHeaders, queryItems: [URLQueryItem]) {
        self.token = nil
        self.dataType = dataType
        self.headers = headers
        self.queryItems = queryItems
    }
        
    init(dataType: DataType ,token: String, headers: HTTPHeaders, queryItems: [URLQueryItem]) {
        self.token = token
        self.dataType = dataType
        self.headers = headers
        self.queryItems = queryItems
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
}


