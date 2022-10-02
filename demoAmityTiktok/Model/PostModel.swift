//
//  VideoModel.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 16/9/2565 BE.
//

import Foundation
import AmitySDK

struct PostModel {
    var owner: UserModel
    var postId: String
    var caption: String
    var amityVideoData: AmityVideoData?
    var thumbnailPathURL: String?
    var videoFilename: String?
    var videoFileFormat: String?
    var reactionsCount: Int
    var commentsCount: Int
    var isLiked: Bool
}
