//
//  AccessInfoModel.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/12.
//

import Foundation

struct AccessInfoModel: Codable {
    var clientId: String?
    var scopes: [String]?
    var token: String?
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case scopes = "scopes"
        case token = "token"
    }
}
