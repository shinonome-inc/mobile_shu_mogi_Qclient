//
//  TagListTableViewCell.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/16.
//

import UIKit

class TagListTableViewCell: UITableViewCell {

    @IBOutlet weak var tagIconImage: UIImageView!
    @IBOutlet weak var tagTitle: UILabel!
    @IBOutlet weak var tagCount: UILabel!
    
    func cellSetLayout() {
        //アイコン画像を丸くする
        tagIconImage.layer.cornerRadius = tagIconImage.frame.size.width * 0.5
    }
    
    func setModel(model: TagData) {
        self.tagTitle.text = model.tagTitle
        self.tagCount.text = "\(model.itemCount)件"
        if let url = URL(string: model.imageURL) {
            do {
                let imageData = try Data(contentsOf: url)
                self.tagIconImage.image = UIImage(data: imageData)
            } catch {
                self.tagIconImage.image = UIImage(named: "no-coupon-image.png")
            }
            self.cellSetLayout()
        }
        
    }
}
