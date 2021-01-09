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
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    
    func setModel(model: UserDetailData) {
        //userNameがない場合の対処
        if model.userName == "" {
            userNameLabel.text = model.userId
        } else {
            userNameLabel.text = model.userName
        }
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
        postCountLabel.text = "post: \(model.itemCount)"
        followersCountLabel.text = "follower: \(model.followerCount)"
        discriptionLabel.text = model.discription
    }
}
