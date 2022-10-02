//
//  EditProfileDataViewController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 22/9/2565 BE.
//

import UIKit
import AmitySDK

class EditProfileDataViewController: UIViewController {

    @IBOutlet weak var currentDataTextField: UITextField!
    @IBOutlet weak var topicTitleLabel: UINavigationItem!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var currentAmityClient: AmityClient!
    var userManager: UserManager!
    
    var user: UserModel!
    var topicProfileDataSelected: String!
    var editProfileVCDelegate: EditProfileViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            userManager = UserManager(amityClient: currentAmityClient, delegate: nil)
        }
        
        /** Check or get current logined user **/
        if user == nil {
            print("No current logined user data for edit profile then get current logined user from amity again.")
            
            /** Get current logined user data **/
            userManager.getCurrentLoginedUserModel()
        }
        
        /** Set data to UI **/
        setDataToUI()
        
    }
    
    func setDataToUI() {
        if let topic = topicProfileDataSelected {
            /** Set UI for edit display name **/
            if topic == "Display Name" {
                descriptionLabel.text = "Edit your display name"
                topicTitleLabel.title = topic
                currentDataTextField.text = user.displayname
                currentDataTextField.placeholder = "Add your display name"
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        /** Dismiss edit profile data view **/
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        /** Save new display name to amity **/
        if let newData = currentDataTextField.text {
            if let topic = topicProfileDataSelected {
                /** Set new display name to user model**/
                if topic == "Display Name" {
                    userManager.setNewDisplayName(to: newData)
                    user.displayname = newData
                }
            }
        }
        
        /** Update new user model to edit profile view controller**/
        editProfileVCDelegate.didEditProfileData(newUserModel: user)
        
        /** Dismiss edit profile data view **/
        dismiss(animated: true, completion: nil)
    }
}

//extension EditProfileDataViewController: UserManagerDelegate {
//    func didSetNewAvatar(newImage: UIImage) {
//    }
//
//    func didGetUserModelByUserID(userModel: UserModel) {
//    }
//
//    func didGetCurrentLoginedUserModel(userModel: UserModel) {
//    }
//
//    func didSearchUserByDisplayName(listUserModel: [UserModel]) {
//    }
//
//}
