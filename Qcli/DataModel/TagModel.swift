//
//  TagModel.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/12.
//

import Foundation

struct TagModel: Codable {
    var followersCount: Int?
    var iconUrl: String?
    var id: String?
    var itemsCount: Int?
    enum CodingKeys: String, CodingKey {
        case followersCount = "followers_count"
        case iconUrl = "icon_url"
        case id = "id"
        case itemsCount = "items_count"
    }
}
