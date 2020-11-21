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
    case user = "user"
    case tag = "tags"
}

class RequestData {
    var result: [Any]!
    var token: String!
    //var headers: HTTPHeaders!
    var dataType: DataType!
    var urlComponents: URLComponents!
    
    init(dataType: DataType) {
        self.dataType = dataType
        self.token = nil
    }
    
    init(dataType: DataType, token: String) {
        self.dataType = dataType
        self.token = token
    }
    
    func fetch() {
        
        guard let dataType = dataType else {
            print("ERROR : No data type has been specified yet.")
            return
        }
        
        switch dataType {
        case .article:
            print("🗞 Article data type has been selected.")
        case .user:
            print("👥 User data type has been selected.")
        case .tag:
            print("🏷 Tag data type has been selected.")
        }
        
        let baseUrl = "https://qiita.com/api/v2/\(dataType.rawValue)"
        
        guard var urlComponents = URLComponents(string: baseUrl) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "20"),
        ]
        
        guard let url = urlComponents.url else {
            print("An error occurred when adding the query.")
            return
        }
        
        print("Request with \(url)")
        
        AF.request(url).response { respose in
            guard let data = respose.data else {
                return
            }
             
            switch dataType {
            case .article:
                guard let result = try? JSONDecoder().decode([AirticleModel].self, from: data) else {
                    print("An error occurred during decoding.")
                    return
                }
                self.result = result
            case .user:
                guard let result = try? JSONDecoder().decode([UserModel].self, from: data) else {
                    print("An error occurred during decoding.")
                    return
                }
                self.result = result
            case .tag:
                guard let result = try? JSONDecoder().decode([TagModel].self, from: data) else {
                    print("An error occurred during decoding.")
                    return
                }
                self.result = result
            }
            
        }
    }
}


