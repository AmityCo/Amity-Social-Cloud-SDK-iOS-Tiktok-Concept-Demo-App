//
//  EditProfileViewController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 21/9/2565 BE.
//

import UIKit
import AmitySDK
import Alamofire
import AlamofireImage

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileDataTableView: UITableView!
    @IBOutlet weak var avatar: UIImageView!
    private var tapToChangeAvatarAction: UITapGestureRecognizer!
    
    var currentAmityClient: AmityClient!
    var userManager: UserManager!
    var user: UserModel!
    var topicProfileDataSelected: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Set custom avatar design **/
        avatar.layer.cornerRadius = avatar.frame.width / 2
        
        /** Check or get amity client **/
        if currentAmityClient == nil {
            print("Current Amity client is nil -> start get new connected amity client")
            
            /** Get registered client from app delegate **/
            if let newConnectedClient = Utilities.Amity.getConnectedClient() {
                currentAmityClient = newConnectedClient
            }
        }
        
        /** Init Manager **/
        if userManager == nil {
            userManager = UserManager(amityClient: currentAmityClient, delegate: self)
        }
        
        /** Get current logined user data **/
        user = userManager.getCurrentLoginedUserModel(isGetFollowInfo: false)

        /** Set delegate **/
        profileDataTableView.dataSource = self
        profileDataTableView.delegate = self
        userManager.delegate = self
        
        /** Set custom cell to table view **/
        profileDataTableView.register(UINib(nibName: "ProfileDataTableViewCell", bundle: nil), forCellReuseIdentifier: "profileDataTableViewCell")
        
        /** Set tap action on avatar **/
        tapToChangeAvatarAction = UITapGestureRecognizer(target: self, action: #selector(self.openChangeAvatarMenu))
        tapToChangeAvatarAction.numberOfTapsRequired = 1
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(tapToChangeAvatarAction)
        
        /** Set profile data to UI **/
        setProfileDataToUI()
        
    }
    
    func setProfileDataToUI() {
        /** Set avatar to UI **/
//        if let currentAvatar = user.avatar {
//            avatar.image = currentAvatar
//        }
        
        Alamofire.request(user.avatarFileURL).responseImage { response in
            if case .success(let image) = response.result {
                self.avatar.image = image
                self.avatar.layer.cornerRadius = self.avatar.frame.width / 2
                self.avatar.clipsToBounds = true
            }
        }
        
        /** Set or reload profile data to UI **/
        profileDataTableView.reloadData()
    }
    
    @objc func openChangeAvatarMenu() {
        Utilities.UI.createChooseMediaMenu(recentViewController: self, mediaType: .photo)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        /** Back up get image from UIImagePickerController to UIImage **/
//        newAvatar = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        
        if let newAvatarImagePathURL = info[.imageURL] as? URL {
            /** Close image picker **/
            picker.dismiss(animated: true, completion: nil)
            
            /** Set new avatar to amity **/
            userManager.setNewAvatar(imagePathURL: newAvatarImagePathURL)
            
            /** Set new avatar to UI **/
            user = userManager.getCurrentLoginedUserModel(isGetFollowInfo: false)
            setProfileDataToUI()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = profileDataTableView.dequeueReusableCell(withIdentifier: "profileDataTableViewCell", for: indexPath) as! ProfileDataTableViewCell
        
        topicProfileDataSelected = "Display Name"
        
        profileDataTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToEditProfileDataView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editProfileDataVC = segue.destination as! EditProfileDataViewController
        editProfileDataVC.user = user
        editProfileDataVC.currentAmityClient = currentAmityClient
        editProfileDataVC.topicProfileDataSelected = topicProfileDataSelected
        editProfileDataVC.editProfileVCDelegate = self
    }
}

extension EditProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = profileDataTableView.dequeueReusableCell(withIdentifier: "profileDataTableViewCell", for: indexPath) as! ProfileDataTableViewCell
        let index = indexPath.row
        
        if index == 0 {
            cell.topic.text = "User ID"
            cell.data.text = "@\(user.userID)"
            cell.arrowSymbol.isHidden = true
            cell.isUserInteractionEnabled = false
            print(#"Current user ID : "@\#(user.userID)""#)
        } else if index == 1 {
            cell.topic.text = "Display Name"
            cell.data.text = user.displayname
            print(#"Current displayname : "\#(user.displayname)""#)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "About you"
    }
    
}

/** Use EditProfileViewControllerDelegate for receive new user model after update profile data **/
extension EditProfileViewController: EditProfileViewControllerDelegate {
    /** Receive new user model after update profile data **/
    func didEditProfileData(newUserModel: UserModel) {
        /** Update new user model from edit profile data view controller **/
        user = newUserModel
        
        /** Set new profile data to view controller **/
        setProfileDataToUI()
    }
}

/** Use UserManagerDelegate for add UIImagepickerController & set new avatar **/
extension EditProfileViewController: UserManagerDelegate {
    func didSetNewAvatar(newImage: UIImage) {
        avatar.image = newImage
    }
    
    /** Don't use **/
    func didGetFollowInfo(amountFollowing: Int, amountFollower: Int) {}
    func didCheckCurrentLoginedUserIsFollowUser(isFollow: Bool) {}
    func didGetUserModelByUserID(userModel: UserModel) {}
    func didGetCurrentLoginedUserModel(userModel: UserModel) {}
    func didSearchUserByDisplayName(listUserModel: [UserModel]) {}
    func didFollowOrUnFollowUser(isFollow: Bool) {}
}

protocol EditProfileViewControllerDelegate {
    func didEditProfileData(newUserModel: UserModel)
}
