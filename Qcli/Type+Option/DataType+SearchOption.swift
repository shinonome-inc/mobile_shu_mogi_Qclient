//
//  RequestData.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/20.
//

import Foundation

enum DataType: String {
    case article = "items"
    case user = "users"
    case tag = "tags"
    case auth = "authenticated_user"
    case oauth = "oauth/authorize"
    case getToken = "access_tokens"
}

enum SearchOption: String, CaseIterable {
    case title = "title"
    case tag = "tag"
    case body = "body"
    case user = "user"
}
