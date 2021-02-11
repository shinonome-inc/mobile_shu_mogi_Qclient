//
//  URL+GetCode.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/11.
//

import Foundation

extension URL {
    func getCode() -> String? {
        let codeKey = "code"
        guard self.scheme == AuthorizeKey.scheme.rawValue else { return nil }
        guard let urlComponent = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = urlComponent.queryItems,
              let code = queryItems.filter({ $0.name == codeKey }).compactMap({ $0.value }).first else { return nil }
        return code
    }
}
