//
//  UserListTableViewCell.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/01/01.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    
    func setModel(model: UserDetailData) {
        userNameLabel.text = model.userName
        userIdLabel.text = "@" + model.userId
        if let url = URL(string: model.imageUrl) {
            userImageView.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(_): break
                case .failure(_):
                    self.userImageView.image = UIImage(named: "no-coupon-image.png")
                }
            })
        }
    }
}
