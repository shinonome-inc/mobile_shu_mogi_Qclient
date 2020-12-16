//
//  ErrorData.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/26.
//

import Foundation

struct ErrorModel: Codable {
    var message: String?
    var type: String?
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case type = "type"
    }
}
