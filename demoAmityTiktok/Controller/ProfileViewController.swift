//
//  ProfileViewController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 21/9/2565 BE.
//

import UIKit
import AmitySDK
import Alamofire
import AlamofireImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var displayNameLabel: UINavigationItem!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var amountFollowingLabel: UILabel!
    @IBOutlet weak var amountFollowerLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var postOnProfileCollectionView: UICollectionView!
    
    var currentAmityClient: AmityClient!
    var user: UserModel!
    var selectedUserID: String!
    var userManager: UserManager!
    var feedManager: FeedManager!
    var listPostOfUser: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Set custom avatar design **/
        avatar.layer.cornerRadius = avatar.frame.width / 2
        
        /** Get registered client from app delegate **/
        if let newConnectedClient = Utilities.Amity.getConnectedClient() {
            currentAmityClient = newConnectedClient
        }
        
        /** Init Manager **/
        userManager = UserManager(amityClient: currentAmityClient, delegate: self)
        feedManager = FeedManager(amityClient: currentAmityClient, delegate: self)
        
        /** Set delegate **/
        postOnProfileCollectionView.dataSource = self
        postOnProfileCollectionView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        /** Set status bar to default content **/
        navigationController?.navigationBar.barStyle = .default
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        /** Check selected user profile **/
        if selectedUserID == nil {
            /** Case : press "Me" on tab bar for get current logined user profile **/
            print(#"Case : press "Me" on tab bar for get current logined user profile"#)
            /** Set user profile to current logined user **/
            user = userManager.getCurrentLoginedUserModel(isGetFollowInfo: true)

            /** Set follow button to hidden **/
            followButton.isHidden = true
        } else {
            /** Case : press avatar or displayname on video post or comment for get other user profile **/
            print(#"Case : press avatar or displayname on video post or comment for get other user profile"#)
            /** Set edit profile button to hidden **/
            editProfileButton.isHidden = true

            /** Set tab bar to hidden **/
            tabBarController?.tabBar.isHidden = true

            /** Get user model for update follow info **/
            user = userManager.getUserModelByUserID(userID: selectedUserID, isGetFollowInfo: true)

            /** Set follow button **/
            userManager.checkCurrentLoginedUserIsFollowUser(otherUserID: selectedUserID)
        }
        
        /** Get post of user **/
        feedManager.queryFeedByUserID(selectedUserID ?? user.userID)
        
        /** Set user profile data to UI **/
        setUserProfileDataToUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        /** Set invalid token for stop observer **/
        print("Set invalid notification token of profile view controller : UserManager = currentLoginedUser, otheruser, checkFollowStatus | FeedManager = otherUserFeed")
        userManager.setInvalidNotificationToken(typeToken: .currentLoginedUser)
        userManager.setInvalidNotificationToken(typeToken: .otheruser)
        userManager.setInvalidNotificationToken(typeToken: .checkFollowStatus)
        userManager.setInvalidNotificationToken(typeToken: .userFollowInfo)
        feedManager.setInvalidNotificationToken(typeToken: .otherUserFeed)
    }
    
    @IBAction func followPressed(_ sender: UIButton) {
        if let followButtonLabel = sender.currentTitle {
            let isFollowValue = followButtonLabel == "Follow" ? true : false
            userManager.followOrUnFollowUser(to: user.userID, isFollow: isFollowValue)
        }
    }
    
    @IBAction func editProfilePressed(_ sender: UIButton) {
        /** Go to edit profile view **/
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /** Set amity client to edit profile view controller before go to its **/
        let editProfileDataVC = segue.destination as! EditProfileViewController
        editProfileDataVC.currentAmityClient = currentAmityClient
    }
    
    func setUserProfileDataToUI() {
        /** Set user profile data to UI **/
        displayNameLabel.title = user.displayname
        userIdLabel.text = "@\(user.userID)"
        amountFollowerLabel.text = String(user.amountFollower)
        amountFollowingLabel.text = String(user.amountFollowing)
        
        Alamofire.request(user.avatarFileURL).responseImage { response in
            if case .success(let image) = response.result {
                self.avatar.image = image
                self.avatar.layer.cornerRadius = self.avatar.frame.width / 2
                self.avatar.clipsToBounds = true
            }
        }
        
    }
}

extension ProfileViewController: UserManagerDelegate {
    func didCheckCurrentLoginedUserIsFollowUser(isFollow: Bool) {
        if isFollow {
            /** Case : follow **/
            followButton.backgroundColor = .lightGray
            followButton.setTitle("Following", for: .normal)
        } else {
            /** Case : unfollow **/
            followButton.backgroundColor = UIColor(named: "MainGreenColor")
            followButton.setTitle("Follow", for: .normal)
        }
    }
    
    func didGetCurrentLoginedUserModel(userModel: UserModel) {
        /** Set new user profile data user model **/
        user = userModel
        
        /** Set new user profile data to UI when user updated **/
        setUserProfileDataToUI()
    }
    
    func didFollowOrUnFollowUser(isFollow: Bool) {
        /** Check follow activity is follow or unfollow **/
        if isFollow {
            /** Case : follow **/
            followButton.backgroundColor = .lightGray
            followButton.setTitle("Following", for: .normal)
        } else {
            /** Case : unfollow **/
            followButton.backgroundColor = UIColor(named: "MainGreenColor")
            followButton.setTitle("Follow", for: .normal)
        }
    }
    
    func didGetFollowInfo(amountFollowing: Int, amountFollower: Int) {
        /** Update follow info to user model **/
        user.amountFollowing = amountFollowing
        user.amountFollower = amountFollower
        
        print("amountFollower : \(amountFollower) | amountFollowing : \(amountFollowing)")
        
        /** Set new user profile data to UI when user updated **/
        setUserProfileDataToUI()
    }
    
    /** Don't use **/
    func didGetUserModelByUserID(userModel: UserModel) {}
    func didSetNewAvatar(newImage: UIImage) {}
    func didSearchUserByDisplayName(listUserModel: [UserModel]) {}
}

extension ProfileViewController: FeedManagerDelegate {
    func didQueryGlobalFeed(listPostModel: [PostModel]) {}
    
    func didQueryFeedByUserID(listPostModel: [PostModel]) {
        listPostOfUser = listPostModel
        postOnProfileCollectionView.reloadData()
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPostOfUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = postOnProfileCollectionView.dequeueReusableCell(withReuseIdentifier: "postVideoCell", for: indexPath)
        let postData = listPostOfUser[indexPath.row]
        Alamofire.request(postData.thumbnailPathURL!).responseImage { response in
            if case .success(let image) = response.result {
                cell.contentView.addSubview(UIImageView(image: image))
            }
        }
        return cell
    }
    
}

extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /** Get profile view controller by storyboard id **/
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "feedPerProfile") as! FeedPerUserViewController
        
        /** Set user and amity client to feed per user view controller **/
        vc.user = user
        vc.selectedCellIndexFromProfile = indexPath
        
        /** Go to feed per user controller by push view controller **/
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    /** Set size video cell of cellection view **/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: postOnProfileCollectionView.frame.size.width / 3, height: postOnProfileCollectionView.frame.size.height / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
