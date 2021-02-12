//
//  QiitaAPI.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/20.
//

import Foundation

struct AirticleModel: Codable {
    var renderBody: String?
    var body: String?
    var coEditing: Bool?
    var commentsCount: Int?
    var createdAt: String?
    var id: String?
    var likesCount: Int?
    var name: String?
    var isPrivate: Bool?
    var reactionsCount: Int?
    var tags: [TagInItem]
    var title: String?
    var updateAt: String?
    var url: String?
    var user: UserModel
    var pageViewsCount: Int?
    enum CodingKeys: String, CodingKey {
        case renderBody = "rendered_body"
        case body = "body"
        case coEditing = "coediting"
        case commentsCount = "comments_count"
        case createdAt = "created_at"
        case id = "id"
        case likesCount = "likes_count"
        case name = "name"
        case isPrivate = "private"
        case reactionsCount = "reaction_count"
        case tags = "tags"
        case title = "title"
        case updateAt = "update_at"
        case url = "url"
        case user = "user"
        case pageViewsCount = "page_views_count"
    }
    
    struct TagInItem: Codable {
        var name: String?
        enum CodingKeys: String, CodingKey {
            case name = "name"
        }
    }
}
