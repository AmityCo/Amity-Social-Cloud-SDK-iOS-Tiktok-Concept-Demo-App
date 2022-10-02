//
//  CommentManager.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 27/9/2565 BE.
//

import Foundation
import AmitySDK

class CommentManager {
    var client: AmityClient
    var delegate: CommentManagerDelegate!
    var userManager: UserManager
    private var commentRepository: AmityCommentRepository!
    private var reactionRepository: AmityReactionRepository!
    private var tokenResult: [AmityNotificationToken] = []
    
    init(amityClient: AmityClient, delegate: CommentManagerDelegate!) {
        self.client = amityClient
        self.delegate = delegate
        self.userManager = UserManager(amityClient: amityClient, delegate: nil)
        self.commentRepository = AmityCommentRepository(client: amityClient)
        self.reactionRepository = AmityReactionRepository(client: amityClient)
    }
    
    func queryCommentByPostID(_ postID: String) {
        print("Start Query comment on post ID : \(postID)")
        
        tokenResult.append(
            commentRepository.getCommentsWithReferenceId(postID, referenceType: .post, filterByParentId: true, parentId: nil, orderBy: .descending, includeDeleted: false).observe({ commentAmityCollection, collectionChange, error in
                /** Get amity comment collection **/
                let listAmityCommentModel = commentAmityCollection.allObjects()
                
                print("Query comment on post ID : \(postID) count : \(listAmityCommentModel.count)")
                
                /** Map list of comment data to my model **/
                let listCommentModel: [CommentModel] = listAmityCommentModel.map { amityCommentModel in
                    
                    /** Get comment detail **/
                    var commentDetail: String?
                    if let commentData = amityCommentModel.data {
                        if let realCommentDetail = commentData["text"] as? String {
                            commentDetail = realCommentDetail
                        }
                    }
                    
                    /** Get current logined user reaction to this comment **/
                    var currentLoginedUserisLiked = false
                    if amityCommentModel.myReactions.contains("like") {
                        currentLoginedUserisLiked = true
                    }
                    
                    /** Get amount like reaction **/
                    var amountLike: Int = 0
                    if let likeReactionOfComment = amityCommentModel.reactions?["like"] as? Int {
                        amountLike = likeReactionOfComment
                    }
                    
                    /** Get user model of comment owner **/
                    let commentOwner = self.userManager.getUserModelByUserID(userID: amityCommentModel.userId)!
                    
                    /** Return mapped comment data from amity model to my model **/
                    return CommentModel(owner: commentOwner,
                                        commentID: amityCommentModel.commentId,
                                        commentDetail: commentDetail ?? "",
                                        timestamp: Utilities.Time.getDateTimeTextByDateEachCase(dateInputed: amityCommentModel.editedAt),
                                        isLiked: currentLoginedUserisLiked,
                                        amountLike: amountLike)
                }
                
                /** Send new list comment model to comment view controller **/
                self.delegate.didQueryCommentByPostID(newListComment: listCommentModel)
            }))
    }
    
    func createNewComment(_ postID: String, detail: String) {
        print(#"Create text comment "\#(detail)" to post ID \#(postID)"#)
        
        tokenResult.append(commentRepository.createComment(forReferenceId: postID, referenceType: .post, parentId: nil, text: detail).observe({ amityComment, error in
            if let currentError = error {
                print(currentError.localizedDescription)
            }
        }))
    }
    
    func likeUnLikeComment(commentID: String, isAddReaction: Bool) {
        if isAddReaction {
            /** Add reaction like **/
            reactionRepository.addReaction("like", referenceId: commentID, referenceType: .comment) { isSuccess, error in
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    print("Add reaction like result : \(isSuccess)")
                }
            }
        } else {
            /** Remove reaction like **/
            reactionRepository.removeReaction("like", referenceId: commentID, referenceType: .comment) { isSuccess, error in
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    print("Remove reaction like result : \(isSuccess)")
                }
            }
        }
    }
}

protocol CommentManagerDelegate {
    func didQueryCommentByPostID(newListComment: [CommentModel])
    func didCommentUpdated()
}
