//
//  PostedArticleSectionView.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/22.
//

import UIKit

class PostedArticleSectionView {
    static func setConfig() -> UIView {
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 12, y: 0, width: 320, height: 28)
        myLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        myLabel.textColor = #colorLiteral(red: 0.5097572207, green: 0.5098338723, blue: 0.5097404122, alpha: 1)
        myLabel.text = "投稿記事"
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: 320, height: 28)
        headerView.backgroundColor = Palette.tableViewSectionBackgroundColor
        headerView.addSubview(myLabel)
        
        return headerView
    }
}
