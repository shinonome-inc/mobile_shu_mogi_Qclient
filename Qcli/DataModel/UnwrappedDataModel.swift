//
//  UnwrappedDataModel.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/31.
//

import Foundation

struct ArticleData {
    var imgURL: String
    var titleText: String
    var createdAt: String
    var likeNumber: Int
    var articleURL: String
}

struct TagData {
    var tagTitle: String
    var imageURL: String
    var itemCount: Int
}

struct UserData {
    var imageUrl: String
    var userName: String
    var userId: String
    var itemCount: Int
}

struct UserDetailData {
    var imageUrl: String
    var userName: String
    var userId: String
    var itemCount: Int
    var discription: String
    var followCount: Int
    var followerCount: Int
}
