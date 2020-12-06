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
        tagIconImage.layer.cornerRadius = tagIconImage.frame.size.width * 0.5
    }
}
