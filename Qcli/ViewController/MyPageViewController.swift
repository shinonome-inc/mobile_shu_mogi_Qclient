//
//  MyPageViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/29.
//

import UIKit

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userDiscriptionLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var follwerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfile()
    }
    
    
    func setProfile() {
        let keychain = KeyChain()
        guard let token = keychain.get() else { return }
        let authRequest = AuthDataNetworkService(token: token)
        authRequest.fetch(success: { (userData) in
            if let name = userData.name {
                self.userNameLabel.text = name
            }
            if let id = userData.id {
                self.userIdLabel.text = id
            }
            if let userDiscription = userData.description {
                self.userDiscriptionLabel.text = userDiscription
            }
            if let followNumber = userData.followeesCount {
                self.followButton.setTitle(" \(followNumber) Follow ", for: .normal)
                if followNumber <= 0 {
                    self.followButton.isEnabled = false
                }
            }
            if let followerNumber = userData.followersCount {
                self.follwerButton.setTitle(" \(followerNumber) Follower ", for: .normal)
                if followerNumber <= 0 {
                    self.follwerButton.isEnabled = false
                }
            }
            if let imgUrl = userData.profileImageUrl,
               let url = URL(string: imgUrl) {
                self.userImageView.setImage(with: url, completionHandler: { result in
                    switch result {
                    case .success(_): break
                    case .failure(_):
                        self.userImageView.image = UIImage(named: "no-coupon-image.png")
                    }
                })
            }
        }, failure: { (error) in
            print("↓ Could not call profile.")
            print(error)
            //のちにエラー画面を作って遷移させる
        })
    }
}
