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
    @IBOutlet weak var likeLabel: UILabel!
    
    func setModel(model: ArticleData) {
        titleLabel.text = model.titleText
        discriptionLabel.text = model.discriptionText
        likeLabel.text = "\(model.likeNumber)like"
    }
}
