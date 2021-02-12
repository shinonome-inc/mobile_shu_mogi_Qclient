//
//  UserModel.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/12.
//

import Foundation
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
