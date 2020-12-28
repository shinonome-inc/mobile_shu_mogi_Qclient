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
    
    func setModel(model: TagData) {
        self.tagTitle.text = model.tagTitle
        self.tagCount.text = "\(model.itemCount)件"
        if let url = URL(string: model.imageURL) {
            tagIconImage.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(_): break
                case .failure(let error):
                    print("⚠️ SetImageError: \(error.localizedDescription)")
                    self.tagIconImage.image = UIImage(named: "no-coupon-image.png")
                }
            })
        }
        
    }
}
