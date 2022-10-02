//
//  FeedPerUserViewController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 1/10/2565 BE.
//

import UIKit
import AmitySDK
import Alamofire
import AlamofireImage

class FeedPerUserViewController: UIViewController {
    
    @IBOutlet weak var videoFeedCollectionView: UICollectionView!
    
    private var currentAmityClient: AmityClient!
    private var videoFeeds: [PostModel] = []
    private var isVideoPaused: Bool = false
    private var feedManager: FeedManager!
    private var userManager: UserManager!
    var user: UserModel!
    
    private var doubleTapAction: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /** Check amity client **/
        if currentAmityClient == nil {
            
            /** Get registered client from app delegate **/
            print("Start get new connected amity client")
            if let newConnectedClient = Utilities.Amity.getConnectedClient() {
                currentAmityClient = newConnectedClient
            }
        }
        
        /** Init Manager **/
        feedManager = FeedManager(amityClient: currentAmityClient, delegate: self)
        userManager = UserManager(amityClient: currentAmityClient, delegate: self)
        
        /** Set double tap action **/
        doubleTapAction = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapAction(selectIndex:)))
        doubleTapAction.numberOfTapsRequired = 2
        doubleTapAction.delaysTouchesBegan = true
        videoFeedCollectionView.addGestureRecognizer(doubleTapAction)
        
        /** Set delegate and register custom cell **/
        videoFeedCollectionView.dataSource = self
        videoFeedCollectionView.delegate = self
        videoFeedCollectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /** Set status bar to light content **/
        navigationController?.navigationBar.barStyle = .black
        
        /** Set tab bar to show **/
        tabBarController?.tabBar.isHidden = false
        
        /** Load feed **/
        loadFeed()
    }
    
    func loadFeed() {
        /** Query global video feed **/
        feedManager.queryFeedByUserID(user.userID)
    }
    
}

extension FeedPerUserViewController: FeedManagerDelegate {
    func didQueryFeedByUserID(listPostModel: [PostModel]) {
        videoFeeds = listPostModel
        videoFeedCollectionView.reloadData()
    }
    
    func didQueryGlobalFeed(listPostModel: [PostModel]) {}
}

extension FeedPerUserViewController: UserManagerDelegate {
    /** Don't use **/
    func didCheckCurrentLoginedUserIsFollowUser(isFollow: Bool) {}
    func didGetFollowInfo(amountFollowing: Int, amountFollower: Int) {}
    func didGetUserModelByUserID(userModel: UserModel) {}
    func didGetCurrentLoginedUserModel(userModel: UserModel) {}
    func didSearchUserByDisplayName(listUserModel: [UserModel]) {}
    func didSetNewAvatar(newImage: UIImage) {}
    func didFollowOrUnFollowUser(isFollow: Bool) {}
}

extension FeedPerUserViewController: VideoCollectionViewCellDelegate {
    /** Go to profile view controller with selected user **/
    func didPressAvatarOrDisplayName(post: PostModel) {
        /** Check selected user isn't current logined user **/
        if post.owner.userID != userManager.getCurrentLoginedUserModel(isGetFollowInfo: false)?.userID {
            /** Get profile view controller by storyboard id **/
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
            
            /** Set user and amity client to comment view controller **/
            vc.user = post.owner
            vc.currentAmityClient = currentAmityClient
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /** Show comment view **/
    func didPressCommentButton(postID: String) {
        
        /** Get scene delegate for add comment view controller **/
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
          return
        }
        
        /** Get comment view controller by storyboard id **/
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "comment") as! CommentViewController
        
        /** Set comment view delegate, amity client & post ID to comment view controller **/
        vc.commentViewDelegate = self
        vc.currentAmityClient = currentAmityClient
        vc.postID = postID
        
        /** Set size of comment view controller **/
        vc.view.frame.origin.y = UIScreen.main.bounds.height
        vc.view.frame.size.height = UIScreen.main.bounds.height * 0.75
        vc.view.isUserInteractionEnabled = true
        
        /** Add comment view controller to subview **/
        sceneDelegate.window?.addSubview(vc.view)
        self.addChild(vc)
        self.didMove(toParent: vc)
        
        /** Set animation for comment view controller added **/
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            vc.view.frame.origin.y = UIScreen.main.bounds.height * 0.25
        }) { finished in }
    }
}

extension FeedPerUserViewController: CommentViewControllerDelegate {
    func pressDismissButton(viewController: UIViewController) {
        /** Deleete comment view controller from press dismiss button **/
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}

extension FeedPerUserViewController: UICollectionViewDataSource {
    
    /** Set data video feed each cell in collection view **/
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postModel = videoFeeds[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCollectionViewCell", for: indexPath) as! VideoCollectionViewCell
        
        print("Init cell index \(indexPath.row)")
        /** Set configure video and delegate **/
        cell.configure(model: postModel, feedManager: feedManager)
        cell.cellDelegate = self
        
        return cell
    }
    
    /** Set amount of cell in collection view **/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoFeeds.count
    }
}


extension FeedPerUserViewController {
    
    /** Set double tap action to like video **/
    @objc func doubleTapAction(selectIndex: Int){
        print("Double tap")
        /** Get touch point of collection view for get index path of cell **/
        let pointInCollectionView = doubleTapAction.location(in: videoFeedCollectionView)
        
        /** Get index path of cell by touch point **/
        if let selectedIndexPath = videoFeedCollectionView.indexPathForItem(at: pointInCollectionView) {
            
            /** Get cell by index path and set like or unlike video **/
            let selectedCell = videoFeedCollectionView.cellForItem(at: selectedIndexPath) as! VideoCollectionViewCell
            
            if let post = selectedCell.postModel {
                if post.isLiked {
                    feedManager.likeUnLikePost(postID: post.postId, isAddReaction: false)
                } else {
                    feedManager.likeUnLikePost(postID: post.postId, isAddReaction: true)
                }
                
            }
        }
    }
}

extension FeedPerUserViewController: UICollectionViewDelegate {
    
    /** Set one tap action on video to play or pause video **/
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("One tap")
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            cell.playOrPauseVideo(isScrollVideo: false)
        }
    }
    
    /** Set scroll action on video will end display to play video when user scroll back **/
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            cell.playOrPauseVideo(isScrollVideo: true)
        }
    }
    
    /** Set scroll action on video will display to play video and clear old video layer for fix duplicate video in some cell **/
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            let video = videoFeeds[indexPath.row]
            cell.configure(model: video, feedManager: feedManager)
        }
    }
}

extension FeedPerUserViewController: UICollectionViewDelegateFlowLayout {
    
    /** Set size video cell of cellection view **/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: videoFeedCollectionView.frame.size.width, height: videoFeedCollectionView.frame.size.height)
    }
}
