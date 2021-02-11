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
    
}

struct UserModel: Codable {
    var description: String?
    var facebookId: String?
    var followeesCount: Int?
    var followersCount: Int?
    var id: String?
    var itemsCount: Int?
    var location: String?
    var name: String?
    var organization: String?
    var permanentId: Int?
    var profileImageUrl: String?
    var teamOnly: Bool?
    var twitterScreenName: String?
    var websiteUrl: String?
    var linkedinId: String?
    var githubLoginName: String?
    enum CodingKeys: String, CodingKey {
        case description = "description"
        case facebookId = "facebook_id"
        case followeesCount = "followees_count"
        case followersCount = "followers_count"
        case id = "id"
        case itemsCount = "items_count"
        case location = "location"
        case name = "name"
        case organization = "organization"
        case permanentId = "permanent_id"
        case profileImageUrl = "profile_image_url"
        case teamOnly = "team_only"
        case twitterScreenName = "twitter_screen_name"
        case websiteUrl = "website_url"
        case linkedinId = "linkedin_id"
        case githubLoginName = "github_login_name"
    }
}

struct TagInItem: Codable {
    var name: String?
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}

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
