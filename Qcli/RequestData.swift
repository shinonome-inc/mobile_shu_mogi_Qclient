//
//  RequestData.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/20.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestData {
    //    var baseUrl = "https://qiita.com/api/v2/"
    //    var path = "items"
    func fetchArticle() {
        
        let baseUrl = "https://qiita.com/api/v2/items"
        
        guard var urlComponents = URLComponents(string: baseUrl) else {
            print("urlComponents = URLComponents(string: url)ではないそうです")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "20"),
        ]
        
        guard let url = urlComponents.url else {
            print("url component error")
            return
        }
        
        AF.request(url).response { respose in
            guard let data = respose.data else {
                print("error: ")
                return
            }
            print(JSON(data).first!)
            print("-----------------------------------------------")
            guard let result = try? JSONDecoder().decode([AirticleModel].self, from: data) else {
                print("ERROR -> JSONDecoder.decode")
                return
            }
            print(result.first!)
            
        }
    }
}


