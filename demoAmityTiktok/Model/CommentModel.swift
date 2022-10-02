//
//  CommentModel.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 21/9/2565 BE.
//

import Foundation

struct CommentModel {
    var owner: UserModel
    var commentID: String
    var commentDetail: String
    var timestamp: String
    var isLiked: Bool
    var amountLike: Int
}
