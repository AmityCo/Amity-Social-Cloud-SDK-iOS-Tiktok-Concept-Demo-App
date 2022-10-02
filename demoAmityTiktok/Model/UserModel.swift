//
//  UserModel.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 23/9/2565 BE.
//

import Foundation
import UIKit

struct UserModel {
    var userID: String
    var displayname: String
    var avatar: UIImage?
    var avatarFileURL: String = ""
    var amountFollowing: Int = 0
    var amountFollower: Int = 0
}
