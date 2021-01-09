//
//  DateFormat+String.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/04.
//

import Foundation

extension String {
    func toJpDateString() -> String? {
        let enUsFormatter = DateFormatter()
        enUsFormatter.locale = Locale(identifier: "en_US_POSIX")
        enUsFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        if let date = enUsFormatter.date(from: self) {
            let jaFormatter = DateFormatter()
            jaFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
            let dateStr = jaFormatter.string(from: date).description
            return dateStr
        }
        return nil
    }
}
