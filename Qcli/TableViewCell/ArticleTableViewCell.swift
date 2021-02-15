//
//  ArticleTableViewCell.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/14.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var articleIconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    
    func setModel(model: ArticleData) {
        titleLabel.text = model.titleText
        if let createdAt = model.createdAt.toJpDateString() {
            discriptionLabel.text = "@\(model.id) 投稿日: \(createdAt) LGTM: \(model.likeNumber)"
        } else {
            discriptionLabel.text = ""
        }
        if let url = URL(string: model.imgURL) {
            articleIconImage.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(_): break
                case .failure(_):
                    self.articleIconImage.image = UIImage(named: "no-coupon-image.png")
                }
            })
        }
        
    }
    
}
