//
//  File.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/08.
//

import Foundation

enum SegueId: String {
    case fromLoginToOAuthController = "fromLoginToOAuthController"
    case fromLoginToTabBarController = "FromLoginToTabBarController"
    case fromFeedToArticle = "GoToArticlePage"
    case fromTagListToTagDetailList = "FromTagListToTagDetailList"
    case fromTagDetailToArticlePage = "FromTagDetailToArticlePage"
    case fromMyPageToArticlePage = "FromMyPageToArticlePage"
    case fromMyPageToUserList = "FromMyPageToUserList"
    case fromUserListToUserDetail = "FromUserListToUserDetail"
    case fromUserDetailToUserList = "FromUserDetailToUserList"
    case fromUserDetailToArticlePage = "FromUserDetailToArticlePage"
    case fromSettingToPrivacyPolicy = "fromSettingToPrivacyPolicy"
    case fromSettingToTermsOfService = "fromSettingToTermsOfService"
}
