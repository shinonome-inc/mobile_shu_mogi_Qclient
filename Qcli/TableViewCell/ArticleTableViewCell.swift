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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellSetLayout() {
        //アイコン画像を丸くする
        articleIconImage.layer.cornerRadius = articleIconImage.frame.size.width * 0.5
    }

}
