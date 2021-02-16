//
//  UserListType.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/31.
//

import Foundation

enum UserListType: String, CaseIterable {
    case follow = "followees"
    case follower = "followers"
    
    var title: String {
        switch self {
        case .follow:
            return "フォロー中"
        case .follower:
            return "フォロワー"
        }
    }    
}
