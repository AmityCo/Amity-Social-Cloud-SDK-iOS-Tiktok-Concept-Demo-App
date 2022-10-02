//
//  SearchUserViewController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 25/9/2565 BE.
//

import UIKit
import AmitySDK

class SearchUserViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchedUserTableView: UITableView!
    
    var currentAmityClient: AmityClient!
    var userManager: UserManager!
    var listSearchUser: [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Check amity client **/
        if currentAmityClient == nil {
            
            /** Get registered client from app delegate **/
            print("Start get new connected amity client")
            if let newConnectedClient = Utilities.Amity.getConnectedClient() {
                currentAmityClient = newConnectedClient
                
                /** Check current logined user **/
                if let currentloginUser = currentAmityClient?.currentUser {
                    if let amityUserObj = currentloginUser.object {
                        print(#"Welcome "\#(amityUserObj.displayName ?? amityUserObj.userId)" to amity tiktok demo app."#)
                    }
                }
            }
        }
        
        /** Init Manager **/
        userManager = UserManager(amityClient: currentAmityClient, delegate: self)
        
        /** Set delegate **/
        searchedUserTableView.dataSource = self
        searchedUserTableView.delegate = self
        searchTextField.delegate = self
        
        /** Register custom cell to search user table view **/
        searchedUserTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
}

extension SearchUserViewController: UserManagerDelegate {
    /** Set list user after search **/
    func didSearchUserByDisplayName(listUserModel: [UserModel]) {
        listSearchUser = listUserModel
        searchedUserTableView.reloadData()
    }
    
    /** Don't use **/
    func didGetFollowInfo(amountFollowing: Int, amountFollower: Int) {}
    func didSetNewAvatar(newImage: UIImage) {}
    func didCheckCurrentLoginedUserIsFollowUser(isFollow: Bool) {}
    func didGetUserModelByUserID(userModel: UserModel) {}
    func didGetCurrentLoginedUserModel(userModel: UserModel) {}
    func didFollowOrUnFollowUser(isFollow: Bool) {}
}

extension SearchUserViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        listSearchUser = []
        
        if let displayname = searchTextField.text {
            if displayname != "" {
                userManager.searchUserByDisplayName(displayname)
            } else {
                searchedUserTableView.reloadData()
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchTextField.text = ""
        
        return true
    }
}

extension SearchUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSearchUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchedUserTableView.dequeueReusableCell(withIdentifier: "userTableViewCell", for: indexPath) as! UserTableViewCell
        let userModel = listSearchUser[indexPath.row]
        
        cell.configure(userModel: userModel)
        
        return cell
    }
    
    
}

extension SearchUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /** Disable highlighted selected cell **/
        searchedUserTableView.deselectRow(at: indexPath, animated: true)
        
        /** Get user model **/
        let userModel = listSearchUser[indexPath.row]
        
        /** Get profile view controller by storyboard id **/
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        
        /** Set user and amity client to comment view controller **/
//        vc.user = userModel
        vc.selectedUserID = userModel.userID
        
        /** Go to profile view controller **/
        navigationController?.pushViewController(vc, animated: true)
    }
}
