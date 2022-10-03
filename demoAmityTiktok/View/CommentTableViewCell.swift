//
//  CommentTableViewCell.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 21/9/2565 BE.
//

import UIKit
import Alamofire
import AlamofireImage

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var displayName: UIButton!
    @IBOutlet weak var commentDetail: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var amountReaction: UILabel!
    
    var commentManager: CommentManager!
    var commentModel: CommentModel?
    var cellDelegate: CommentTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /** Set custom avatar design **/
//        avatar.layer.cornerRadius = avatar.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func pressAvatarOrDisplayName(_ sender: UIButton) {
        print("pressAvatarOrDisplayName")
        if let comment = commentModel {
            cellDelegate?.didPressAvatarOrDisplayName(comment: comment)
        }
    }
    
    
    @IBAction func pressLikeButton(_ sender: UIButton) {
        if let comment = commentModel {
            if comment.isLiked {
                /** Set unlike if comment is liked**/
                commentManager.likeUnLikeComment(commentID: comment.commentID, isAddReaction: false)
            } else {
                /** Set like if comment is unliked **/
                commentManager.likeUnLikeComment(commentID: comment.commentID, isAddReaction: true)
            }
            
        }
    }
    
    func setLikeUnLikeComment(isInit: Bool) {
        func setColorLikeButton(hightLighted: Bool) {
            /** Set like button to pink **/
            if hightLighted {
                if #available(iOS 15.0, *) {
                    likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.systemPink, .systemPink, .systemPink])), for: .normal)
                }
            /** Set like button to none **/
            } else {
                if #available(iOS 15.0, *) {
                    likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.lightGray, .lightGray, .lightGray])), for: .normal)
                }
            }
        }
        
        if let comment = commentModel {
            /** Case : init social data in video **/
            if isInit {
                /** Like video **/
                if comment.isLiked {
                    setColorLikeButton(hightLighted: true)
                /** Unlike video **/
                } else {
                    setColorLikeButton(hightLighted: false)
                }
            /** Case : press like button **/
            } else {
                /** Unlike video if user press like button highlighted **/
                if comment.isLiked {
                    setColorLikeButton(hightLighted: false)
                    commentModel?.isLiked = false
                /** Like video if user press like button or double tap on video **/
                } else {
                    setColorLikeButton(hightLighted: true)
                    commentModel?.isLiked = true
                }
            }
        }
    }
    
    func configure(commentModel: CommentModel, manager: CommentManager, vc: CommentTableViewCellDelegate) {
        self.commentModel = commentModel
        commentManager = manager
        cellDelegate = vc
        
        displayName.setTitle(commentModel.owner.displayname, for: .normal)
        commentDetail.text = commentModel.commentDetail
        timeStamp.text = commentModel.timestamp
        amountReaction.text = String(commentModel.amountLike)
//        if let avatarCommentOwner = commentModel.owner.avatar {
//            avatar.setBackgroundImage(avatarCommentOwner, for: .normal)
//            avatar.layer.cornerRadius = avatar.frame.width / 2
//        }
        
        Alamofire.request(commentModel.owner.avatarFileURL).responseImage { response in
            if case .success(let image) = response.result {
                self.avatar.setBackgroundImage(image, for: .normal)
                self.avatar.layer.cornerRadius = self.avatar.frame.width / 2
                self.avatar.clipsToBounds = true
            }
        }
        
        setLikeUnLikeComment(isInit: true)
    }
    
}

protocol CommentTableViewCellDelegate {
    func didPressAvatarOrDisplayName(comment: CommentModel)
}
