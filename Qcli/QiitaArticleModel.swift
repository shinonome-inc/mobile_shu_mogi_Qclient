//
//  QiitaAPI.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/20.
//

import Foundation
import Alamofire

struct AirticleModel: Codable {
    var renderBody: String
    var body: String
    var coEditing: Bool
    var commentsCount: Int
    var createdAt: String
    var group: GroupModel
    var id: Int
    var name: String
    var pravate: Bool
    var reactionsCount: Int
    var tags: TagModel
    var title: String
    var updateAt: String
    var url: String
    var user: UserModel
    var pageViewsCount: Int
}

struct UserModel: Codable {
    var description: String
    var facebookId: String
    var followeesCount: Int
    var followersCount: Int
    var githubLoginName: String
    var id: String
    var itemsCount: Int
    var linkedinId: String
    var location: String
    var name: String
    var organization: String
    var permanentId: Int
    var profileImageUrl: String
    var teamOnly: Bool
    var twitterScreenName: String
    var websiteUrl: String
    var imageMonthlyUploadLimit: Int
    var imageMonthlyUploadRemaining: Int
}

struct TagModel: Codable {
    var followersCount: Int
    var iconUrl: String
    var id: String
    var itemsCount: Int
}

struct GroupModel: Codable {
    var createdAt: String
    var id: Int
    var name: String
    var isPrivate: Bool
    var updateedAt: String
    var urlName: String
}
