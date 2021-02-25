//
//  UIButton+MutableAttributedString.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/22.
//

import UIKit

extension UIButton {
    //数字を強調、単位をグレーにフォント設定させるメソッド
    func setMutableAttributedString(number: String, unit: String) {
        let stringAttributes1: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.label,
            .font : UIFont.boldSystemFont(ofSize: 12.0)
        ]
        let string1 = NSAttributedString(string: number, attributes: stringAttributes1)

        let stringAttributes2: [NSAttributedString.Key : Any] = [
            .foregroundColor : #colorLiteral(red: 0.5097572207, green: 0.5098338723, blue: 0.5097404122, alpha: 1),
            .font : UIFont.systemFont(ofSize: 12.0)
        ]
        let string2 = NSAttributedString(string: unit, attributes: stringAttributes2)

        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(string1)
        mutableAttributedString.append(string2)
        
        self.setAttributedTitle(mutableAttributedString, for: .normal)
    }
}
