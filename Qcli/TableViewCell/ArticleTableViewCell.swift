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
    
    func cellSetLayout() {
        //アイコン画像を丸くする
        articleIconImage.layer.cornerRadius = articleIconImage.frame.size.width * 0.5
    }
    
    func setModel(model: ArticleData) {
        self.titleLabel.text = model.titleText
        self.discriptionLabel.text = model.discriptionText
        self.likeLabel.text = "\(model.likeNumber)like"
        if let url = URL(string: model.imgURL) {
            do {
                let imageData = try Data(contentsOf: url)
                self.articleIconImage.image = UIImage(data: imageData)
            } catch {
                self.articleIconImage.image = UIImage(named: "no-coupon-image.png")
            }
            self.cellSetLayout()
        }
        
    }

}
