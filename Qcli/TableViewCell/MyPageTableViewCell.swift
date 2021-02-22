//
//  File.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/29.
//

import UIKit

class MyPageTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    
    func setModel(model: ArticleData) {
        titleLabel.text = model.titleText
        if let createdAt = model.createdAt.toJpDateString() {
            discriptionLabel.text = "投稿日：\(createdAt) LGTM：\(model.likeNumber)"
        } else {
            discriptionLabel.text = ""
        }
    }
}
