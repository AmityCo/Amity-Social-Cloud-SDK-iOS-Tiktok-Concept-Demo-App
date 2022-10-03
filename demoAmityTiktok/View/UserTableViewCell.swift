//
//  UserTableViewCell.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 25/9/2565 BE.
//

import UIKit
import Alamofire
import AlamofireImage

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    
    var userModel: UserModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
            
            Alamofire.request(user.avatarFileURL).responseImage { response in
                if case .success(let image) = response.result {
                    self.avatar.image = image
                    self.avatar.layer.cornerRadius = self.avatar.frame.width / 2
                    self.avatar.clipsToBounds = true
                }
            }
            
        }
    }
    
}
