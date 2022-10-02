//
//  FeedManager.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 26/9/2565 BE.
//

import UIKit
import AmitySDK

class FeedManager {
    var client: AmityClient
    var userManager: UserManager
    var delegate: FeedManagerDelegate!
    private var postRepository: AmityPostRepository
    private var fileRepository: AmityFileRepository
    private var feedRepository: AmityFeedRepository
    private var reactionRepository: AmityReactionRepository
    private let staticCommunityID: String = "62c68c9cba28b100d9a3213a"
    private var globalFeedTokenResult: AmityNotificationToken!
    private var otherUserFeedTokenResult: AmityNotificationToken!
    
    init(amityClient: AmityClient, delegate: FeedManagerDelegate?) {
        self.client = amityClient
        self.userManager = UserManager(amityClient: amityClient, delegate: nil)
        self.delegate = delegate
        self.postRepository = AmityPostRepository(client: amityClient)
        self.reactionRepository = AmityReactionRepository(client: amityClient)
        self.fileRepository = AmityFileRepository(client: amityClient)
        self.feedRepository = AmityFeedRepository(client: amityClient)
    }
    
    func queryGlobalFeed() {
        globalFeedTokenResult = feedRepository.getGlobalFeed().observe { postAmityCollection, collectionChange, error in
            /** Get amity post model **/
            let listAmityPostModel = postAmityCollection.allObjects()
            print("Query all global feed count : \(listAmityPostModel.count)")
            
            /** Map data to post model **/
            var listPostModel: [PostModel] = listAmityPostModel.map { amityPostModel in
                /** Get current logined user reaction to this comment **/
                var currentLoginedUserisLiked = false
                if amityPostModel.myReactions.contains("like") {
                    currentLoginedUserisLiked = true
                }
                
                /** Get amount like reaction **/
                var amountLike: Int = 0
                if let likeReactionOfPost = amityPostModel.reactions?["like"] as? Int {
                    amountLike = likeReactionOfPost
                }
                
                /** Get caption **/
                var caption = "<no caption>"
                if let currentCaption = amityPostModel.data?["text"] as? String {
                    caption = currentCaption
                }
                
                /** Get video post data**/
                var videoPostData: AmityVideoData!
                if let childrenPosts = amityPostModel.childrenPosts {
                    if childrenPosts.count > 0 {
                        if let videoInfo = childrenPosts[0].getVideoInfo() {
                            videoPostData = videoInfo
                        }
                    }
                }
                
                /** Get user model of post owner **/
                let postOwner = self.userManager.getUserModelByUserID(userID: amityPostModel.postedUserId, isGetFollowInfo: false)!
                
                return PostModel(
                    owner: postOwner,
                    postId: amityPostModel.postId,
                    caption: caption,
                    amityVideoData: videoPostData,
                    reactionsCount: amountLike,
                    commentsCount: Int(amityPostModel.commentsCount),
                    isLiked: currentLoginedUserisLiked)
            }
            
            /** Filter post to video only **/
            listPostModel = listPostModel.filter({ postModel in
                return postModel.amityVideoData != nil
            })
            print("Filtered video global feed count : \(listPostModel.count)")
            
            /** Send list post model to view controller **/
            self.delegate?.didQueryGlobalFeed(listPostModel: listPostModel)
        }
    }
    
    func queryFeedByUserID(_ userID: String) {
        /** Get user model of post owner **/
        if let postOwner = userManager.getUserModelByUserID(userID: userID, isGetFollowInfo: false) {
            /** Set query post option **/
            let queryPostOption = AmityPostQueryOptions(
                targetType: .user,
                targetId: userID,
                sortBy: .lastCreated,
                deletedOption: .notDeleted,
                filterPostTypes: nil)
            
            /** Get post by query post option and set observer **/
            otherUserFeedTokenResult = postRepository.getPosts(queryPostOption).observe { amityPostCollection, change, error in
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    /** Get amity post model **/
                    let listAmityPostModel = amityPostCollection.allObjects()
                    print(#"Query post of USER ID "\#(userID)" count : \#(listAmityPostModel.count)"#)
                    
                    /** Map data to post model **/
                    var listPostModel: [PostModel] = listAmityPostModel.map { amityPostModel in
                        /** Get current logined user reaction to this comment **/
                        var currentLoginedUserisLiked = false
                        if amityPostModel.myReactions.contains("like") {
                            currentLoginedUserisLiked = true
                        }

                        /** Get amount like reaction **/
                        var amountLike: Int = 0
                        if let likeReactionOfPost = amityPostModel.reactions?["like"] as? Int {
                            amountLike = likeReactionOfPost
                        }

                        /** Get caption **/
                        var caption = "<no caption>"
                        if let currentCaption = amityPostModel.data?["text"] as? String {
                            caption = currentCaption
                        }

                        /** Get video post data**/
                        let videoPostData = amityPostModel.getVideoInfo()

                        /** Get thumbnail of video **/
                        var thumbnailPathID: String = ""
                        if let thumbnailVideoInfo = amityPostModel.data?["thumbnailFileId"] as? String {
                            thumbnailPathID = thumbnailVideoInfo
                        }

                        return PostModel(
                            owner: postOwner,
                            postId: amityPostModel.postId,
                            caption: caption,
                            amityVideoData: videoPostData,
                            thumbnailPathURL: "https://api.sg.amity.co/api/v3/files/\(thumbnailPathID)/download?size=medium",
                            reactionsCount: amountLike,
                            commentsCount: Int(amityPostModel.commentsCount),
                            isLiked: currentLoginedUserisLiked)
                    }
                    
                    /** Filter post to video only **/
                    listPostModel = listPostModel.filter({ postModel in
                        return postModel.amityVideoData != nil
                    })
                    print(#"Filtered video post of USER ID "\#(userID)" count : \#(listPostModel.count)"#)
                    
                    /** Send list post model to view controller **/
                    self.delegate.didQueryFeedByUserID(listPostModel: listPostModel)
                }
            }
        } else {
            print("Error get post by user id : user id not found")
        }
    }
    
    func createNewVideoPost(videoPathURL: URL, caption: String) {
        /** Show progress pop up **/
        let progressPopup = Utilities.UI.showProgressPopup(recentViewController: delegate as! UIViewController)
        
        /** Upload video from path to Amity **/
        fileRepository.uploadVideo(with: videoPathURL) { progressPercent in
            
            /** Update progress bar **/
            progressPopup.message = String(format: "%.0f", progressPercent * 100) + "%"
            
        } completion: { recentUploadAmityVideoData, error in
            /** Update progress bar to 100% **/
            progressPopup.message = "100%"
            
            /** Create video post builder **/
            let videoPostBuilder = AmityVideoPostBuilder()
            videoPostBuilder.setText(caption)
            videoPostBuilder.setVideos([recentUploadAmityVideoData!])
            
            /** Get current logined user **/
            let currentLoginedUser = self.userManager.getCurrentLoginedUserModel(isGetFollowInfo: false)
            
            /** Create post with post builder **/
            self.postRepository.createPost(videoPostBuilder, targetId: currentLoginedUser?.userID, targetType: .user) { amityPost, error in
                
                /** Dismiss progress pop up **/
                progressPopup.dismiss(animated: true)
                
                /** Show success pop up**/
                Utilities.UI.showAlertPopup(title: "Success", detail: "Create new video post success", type: .OK_WITH_POP_VIEW, recentViewController: self.delegate! as! UIViewController)
            }
        }
    }
    
    func likeUnLikePost(postID: String, isAddReaction: Bool) {
        if isAddReaction {
            /** Add reaction like **/
            reactionRepository.addReaction("like", referenceId: postID, referenceType: .post) { isSuccess, error in
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    print("Add reaction like result : \(isSuccess)")
                }
            }
        } else {
            /** Remove reaction like **/
            reactionRepository.removeReaction("like", referenceId: postID, referenceType: .post) { isSuccess, error in
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    print("Remove reaction like result : \(isSuccess)")
                }
            }
        }
    }
    
    func setInvalidNotificationToken(typeToken: typeTokenOfFeedManager) {
        switch typeToken {
        case .globalFeed:
            globalFeedTokenResult = nil
        case .otherUserFeed:
            otherUserFeedTokenResult = nil
        }
    }
}

enum typeTokenOfFeedManager {
    case globalFeed
    case otherUserFeed
}

protocol FeedManagerDelegate {
    func didQueryGlobalFeed(listPostModel: [PostModel])
    func didQueryFeedByUserID(listPostModel: [PostModel])
}
