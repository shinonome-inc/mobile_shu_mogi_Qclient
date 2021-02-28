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
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var highlightView: UIView!
    
    func setModel(model: UserDetailData) {
        selectionStyle = .none
        
        setBorderView()
        setHighlightView()
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
    
    func setBorderView() {
        borderView.layer.cornerRadius = 8
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 0.85)
    }
    
    func setHighlightView() {
        highlightView.layer.cornerRadius = 8
        highlightView.isHidden = true
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            highlightView.isHidden = false
        } else {
            highlightView.isHidden = true
        }
    }
}
