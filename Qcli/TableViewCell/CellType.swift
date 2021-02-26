//
//  CellType.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/07.
//

import Foundation

enum AppInfoCellType: Int, CaseIterable {
    case pp
    case tos
    case ver
    var titleMessage: String {
        switch self {
        case .pp:
            return "プライバシーポリシー"
        case .tos:
            return "利用規約"
        case .ver:
            return "アプリバージョン"
        }
    }
}

enum OtherCellType: Int, CaseIterable {
    case logout
    var titleMessage: String {
        switch self {
        case .logout:
            return "ログアウトする"
        }
    }
}
