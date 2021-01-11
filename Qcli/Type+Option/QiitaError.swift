//
//  QiitaError.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/10.
//

import Foundation

enum QiitaError: Error {
    case connectionError
    case responseParseError
    case apiError
    var errorMessage: String {
        switch self {
        case .connectionError:
            return "ネットワーク状況を確認し、再度お試しください。"
        case .responseParseError:
            return "お探しのページが得られませんでした。"
        case .apiError:
            return "データの取得に失敗しました。"
        }
    }
}
