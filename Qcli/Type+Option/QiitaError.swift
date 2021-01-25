//
//  QiitaError.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/10.
//

import Foundation

enum QiitaError: Error {
    case connectionError
    case rateLimitExceededError
    case unauthorizedError
    case unexpectedError
    var errorMessage: String {
        switch self {
        case .connectionError:
            return "ネットワーク状況を確認し、再度お試しください。"
        case .rateLimitExceededError:
            return "情報取得回数が制限を超えました。しばらくしてから再度お試しください。"
        case .unauthorizedError:
            return "トークンが無効もしくはトークンが入力されていません。ログイン画面に戻ってトークン情報を入力してください。"
        case .unexpectedError:
            return "予期せぬエラーが発生しました。"
        }
    }
}
