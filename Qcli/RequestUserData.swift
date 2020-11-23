//
//  RequestUserData.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/23.
//

import Foundation
import Alamofire

class RequestUserData {
    var token: String!
    //var headers: HTTPHeaders!
    var urlComponents: URLComponents!
    let dataType: DataType = .user
    
    init() {
        self.token = nil
    }
        
    init(token: String) {
        self.token = token
    }
    
    func fetch(success: @escaping ((_ result: [UserModel]?) -> Void), failure: @escaping ((_ error: NSError?) -> Void)) {
        
        let baseUrl = "https://qiita.com/api/v2/\(dataType.rawValue)"
        
        guard var urlComponents = URLComponents(string: baseUrl) else {
            return
        }
        
//        urlComponents.queryItems = [
//            URLQueryItem(name: "page", value: "1"),
//            URLQueryItem(name: "per_page", value: "20"),
//        ]
        
        guard let url = urlComponents.url else {
            print("An error occurred when adding the query.")
            return
        }
        
        print("Request with \(url)")
        
        AF.request(url).response { respose in
            guard let data = respose.data else {
                return
            }
            
            guard let exportData = try? JSONDecoder().decode([UserModel].self, from: data) else {
                print("An error occurred during decoding.")
                failure(respose.error as NSError?)
                return
            }
            success(exportData)
            
            
            
        }
    }
}


