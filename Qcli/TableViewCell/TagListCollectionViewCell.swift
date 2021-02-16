//
//  TagListTableViewCell.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/16.
//

import UIKit

class TagListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagIconImage: UIImageView!
    @IBOutlet weak var tagTitle: UILabel!
    @IBOutlet weak var tagCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    
    func setModel(model: TagData) {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        tagTitle.text = model.tagTitle
        tagCount.text = "記事件数：\(model.itemCount)件"
        followersCount.text = "フォロワー数：\(model.followersCount)人"
        if let url = URL(string: model.imageURL) {
            tagIconImage.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(_): break
                case .failure(_):
                    self.tagIconImage.image = UIImage(named: "no-coupon-image.png")
                }
            })
        }
        
    }
}
