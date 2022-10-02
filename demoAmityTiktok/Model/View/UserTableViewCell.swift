//
//  UserTableViewCell.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 25/9/2565 BE.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    
    var userModel: UserModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /** Set custom avatar design **/
        avatar.layer.cornerRadius = avatar.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(userModel: UserModel) {
        self.userModel = userModel
        configureSocialData()
    }
    
    private func configureSocialData() {
        if let user = userModel {
            displaynameLabel.text = user.displayname
            userIDLabel.text = "@\(user.userID)"
            if let avatarUser = user.avatar {
                avatar.image = avatarUser
            }
        }
    }
    
}
