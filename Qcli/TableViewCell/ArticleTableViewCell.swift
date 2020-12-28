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
    @IBOutlet weak var likeLabel: UILabel!
    
    func setModel(model: ArticleData) {
        self.titleLabel.text = model.titleText
        self.discriptionLabel.text = model.discriptionText
        self.likeLabel.text = "\(model.likeNumber)like"
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
