//
//  ArticleTableViewCell.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/14.
//

import UIKit
import Kingfisher

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
            articleIconImage.kf.setImage(with: url, completionHandler:  { result in
                switch result {
                case .failure(let error):
                    print("⚠️ SetImageError: \(error.localizedDescription)")
                    self.articleIconImage.image = UIImage(named: "no-coupon-image.png")
                case .success(_): break
                }
            })
        }
        
    }

}
