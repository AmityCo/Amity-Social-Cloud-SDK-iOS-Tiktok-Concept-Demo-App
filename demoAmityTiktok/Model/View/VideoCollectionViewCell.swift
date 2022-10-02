//
//  VideoCollectionViewCell.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 16/9/2565 BE.
//

import UIKit
import AVFoundation
import Alamofire
import AlamofireImage

class VideoCollectionViewCell: UICollectionViewCell {
    
    /** Static info about VideoCollectionViewCell **/
    static let identifier = "videoCollectionViewCell"
    
    /** UI Element linked to XIB   **/
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var displayNameLabel: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var avatar: UIButton!
    @IBOutlet weak var amountLikeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var amountCommentLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    /** Video element and static value for process **/
    var videoPlayer: AVPlayer?
    var postModel: PostModel?
    var feedManager: FeedManager!
    private var isPaused: Bool = false
    
    /** Delegate **/
    var cellDelegate: VideoCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /** Set custom avatar design **/
        avatar.layer.cornerRadius = avatar.frame.width / 2
        
        /** Set design comment button to big **/
        if #available(iOS 15.0, *) {
            commentButton.setImage(UIImage(systemName: "message.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.white, .white, .white])), for: .normal)
        }
    }
    
    override func prepareForReuse() {
//        super.prepareForReuse()
        videoView.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    }
    
    
    @IBAction func pressAvatarOrDisplayName(_ sender: UIButton) {
        if let post = postModel {
            cellDelegate?.didPressAvatarOrDisplayName(post: post)
        }
    }
    
    @IBAction func pressCommentButton(_ sender: UIButton) {
        /** Send back to view controller **/
        if let post = postModel {
            cellDelegate?.didPressCommentButton(postID: post.postId)
        }
    }
    
    @IBAction func pressLikeButton(_ sender: UIButton) {
        if let post = postModel {
            if post.isLiked {
                feedManager.likeUnLikePost(postID: post.postId, isAddReaction: false)
            } else {
                feedManager.likeUnLikePost(postID: post.postId, isAddReaction: true)
            }
            
        }
    }
    
    public func configure(model: PostModel, feedManager: FeedManager) {
        self.postModel = model
        self.feedManager = feedManager
        /** Set video and social data to cell **/
        configureVideo()
        configureSocialData()
    }
    
    func configureVideo() {
        if let video = postModel?.amityVideoData {
            print("Debug video data from amity")
            print(video)
            
            /** Set path for get video **/
            guard
                let url = URL(string: video.fileURL) else {
                return
            }
            
            /** Setting video player with path **/
            videoPlayer = AVPlayer(url: url)
            videoPlayer?.volume = 0
            
            /** Init video view **/
            let videoLayer = AVPlayerLayer()
            videoLayer.player = videoPlayer
            videoLayer.frame = contentView.bounds
            videoLayer.videoGravity = .resizeAspect
            
            /** Remove old layer if exist for fix duplicate in some cell when scroll **/
            if let latestLayer = videoView.layer.sublayers {
                latestLayer[0].removeFromSuperlayer()
            }
            
            /** Add video layer to view **/
            videoView.layer.addSublayer(videoLayer)
            
            /** Set video layer to behind  **/
            videoView.layer.anchorPointZ = 1
            
            /** Play video **/
            videoPlayer?.play()
        }
    }
    
    func configureSocialData() {
        if let post = postModel {
            /** Set like data and button **/
            setLikeUnLikeVideo(isInit: true)
            
            /** Set social data of post **/
            amountLikeLabel.text = String(post.reactionsCount)
            amountCommentLabel.text = String(post.commentsCount)
            displayNameLabel.setTitle(post.owner.displayname, for: .normal)
            captionLabel.text = post.caption
//            if let avatarOfPostOwner = post.owner.avatar {
//                avatar.setBackgroundImage(avatarOfPostOwner, for: .normal)
//                avatar.layer.cornerRadius = avatar.frame.width / 2
//            }
            
            Alamofire.request(post.owner.avatarFileURL).responseImage { response in
                if case .success(let image) = response.result {
                    self.avatar.setBackgroundImage(image, for: .normal)
                    self.avatar.layer.cornerRadius = self.avatar.frame.width / 2
                    self.avatar.clipsToBounds = true
                }
            }

        }
    }
    
    func playOrPauseVideo(isScrollVideo: Bool) {
        /** Play video if video paused or user scroll to other video **/
        if isPaused || isScrollVideo {
            videoPlayer?.play()
            isPaused = false
            /** Pause video if video playing **/
        } else {
            videoPlayer?.pause()
            isPaused = true
        }
    }
    
    func setLikeUnLikeVideo(isInit: Bool) {
        func setColorLikeButton(hightLighted: Bool) {
            /** Set like button to pink **/
            if hightLighted {
                if #available(iOS 15.0, *) {
                    likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.systemPink, .systemPink, .systemPink])), for: .normal)
                }
                /** Set like button to white **/
            } else {
                if #available(iOS 15.0, *) {
                    likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.white, .white, .white])), for: .normal)
                }
            }
        }
        
        if let post = postModel {
            /** Case : init social data in video **/
            if isInit {
                /** Like video **/
                if post.isLiked {
                    setColorLikeButton(hightLighted: true)
                    /** Unlike video **/
                } else {
                    setColorLikeButton(hightLighted: false)
                }
                /** Case : press like button **/
            } else {
                /** Unlike video if user press like button highlighted **/
                if post.isLiked {
                    setColorLikeButton(hightLighted: false)
                    postModel?.isLiked = false
                    /** Like video if user press like button or double tap on video **/
                } else {
                    setColorLikeButton(hightLighted: true)
                    postModel?.isLiked = true
                }
            }
        }
    }
}

protocol VideoCollectionViewCellDelegate {
    func didPressCommentButton(postID: String)
    func didPressAvatarOrDisplayName(post: PostModel)
}
