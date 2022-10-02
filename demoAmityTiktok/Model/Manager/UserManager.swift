//
//  UserManager.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 26/9/2565 BE.
//

import Foundation
import AmitySDK

class UserManager {
    var client: AmityClient?
    var userRepository: AmityUserRepository!
    var fileRepository: AmityFileRepository!
    private var tokenResult: [AmityNotificationToken] = []
    
    var delegate: UserManagerDelegate!
    
    init(amityClient: AmityClient, delegate: UserManagerDelegate?) {
        self.client = amityClient
        self.userRepository = AmityUserRepository(client: amityClient)
        self.fileRepository = AmityFileRepository(client: amityClient)
        self.delegate = delegate
    }
    
    func getCurrentLoginedUserModel() -> UserModel? {
        /** Get current logined user by client **/
        if let amityUserModelLiveObj = client?.currentUser {
            /** Add observer when current logined user updated **/
            if delegate != nil {
                tokenResult.append(amityUserModelLiveObj.observe({ amityUserObj, error in
                    print("Trigger updated from amityUserModelLiveObj observer -> update new amity user model to viewcontroller")
                    if let amityUserModel = amityUserObj.object {
                        /** Map data to user model **/
                        let newUserModel = self.mapDataToUserModel(amityUserModel: amityUserModel)
                        
                        /** Set observer for get following/follower data if delegate is profile view controller **/
                        if let profileViewController = self.delegate as? ProfileViewController {
                            self.getFollowInfo(of: amityUserModel.userId)
                        }
                        
                        /** Send user model to delegate **/
                        self.delegate.didGetCurrentLoginedUserModel(userModel: newUserModel)
                    }
                }))
            }

            /** Return current logined user model **/
            if let amityUserModel = amityUserModelLiveObj.object {
                /** Map data to user model **/
                let newUserModel = self.mapDataToUserModel(amityUserModel: amityUserModel)
                
                /** Set observer for get following/follower data if delegate is profile view controller **/
                if let profileViewController = delegate as? ProfileViewController {
                    self.getFollowInfo(of: amityUserModel.userId)
                }
                
                /** Return user model **/
                return newUserModel
            }
        }
        
        return nil
    }
    
    func getUserModelByUserID(userID: String) -> UserModel? {
        /** Get user by user ID in Amity **/
        let resultAmityUserModel = userRepository.getUser(userID)
        
        /** Add observer when other user updated **/
        if delegate != nil {
            tokenResult.append(resultAmityUserModel.observe { amityUserObj, error in
                if let amityUserModel = amityUserObj.object {
                    /** Map data to user model **/
                    let newUserModel = self.mapDataToUserModel(amityUserModel: amityUserModel)
                    
                    /** Set observer for get following/follower data if delegate is profile view controller **/
                    if let profileViewController = self.delegate as? ProfileViewController {
                        self.getFollowInfo(of: amityUserModel.userId)
                    }
                    
                    /** Send user model to delegate **/
                    self.delegate.didGetUserModelByUserID(userModel: newUserModel)
                }
            })
        }
        
        /** Return user model **/
        if let amityUserModel = resultAmityUserModel.object {
            /** Map data to user model **/
            let newUserModel = self.mapDataToUserModel(amityUserModel: amityUserModel)
            
            /** Set observer for get following/follower data if delegate is profile view controller **/
            if let profileViewController = delegate as? ProfileViewController {
                self.getFollowInfo(of: amityUserModel.userId)
            }
            
            /** Return user model **/
            return newUserModel
        }
        
        return nil
    }
    
    private func mapDataToUserModel(amityUserModel: AmityUser) -> UserModel {
        /** Get and set avatar info UIImage **/
        var avatarPathURL: String = ""
        if let avatarInfo = amityUserModel.getAvatarInfo() {
            avatarPathURL = avatarInfo.fileURL
        }
        
        /** Return user model **/
        return UserModel(userID: amityUserModel.userId, displayname: amityUserModel.displayName ?? amityUserModel.userId, avatarFileURL: avatarPathURL)
    }
    
    private func getFollowInfo(of userID: String?) {
        let followManager = userRepository.followManager
        var amountFollower = 0
        var amountFollowing = 0
        
        if let otherUserID = userID {
            /** Case : Get follow info of other user ID **/
            let otherUserFollowInfo = followManager.getUserFollowInfo(withUserId: otherUserID)
            tokenResult.append(otherUserFollowInfo.observe({ amityUserFollowInfo, error in
                /** Check error and get follow info**/
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    let amityUserFollowInfoObj = amityUserFollowInfo.object
                    amountFollowing = amityUserFollowInfoObj?.followingCount ?? 0
                    amountFollower = amityUserFollowInfoObj?.followersCount ?? 0
                }
                
                /** Send follow info to view controller  and update to model by delegate **/
                self.delegate.didGetFollowInfo(amountFollowing: amountFollowing, amountFollower: amountFollower)
            }))
            
        } else {
            /** Case : Get follow info of mine **/
            let myFollowInfo = followManager.getMyFollowInfo()
            tokenResult.append(myFollowInfo.observe({ amityMyFollowInfo, error in
                /** Check error and get follow info**/
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    let amityMyFollowInfoObj = amityMyFollowInfo.object
                    amountFollowing = amityMyFollowInfoObj?.followingCount ?? 0
                    amountFollower = amityMyFollowInfoObj?.followersCount ?? 0
                }
                
                /** Send follow info to view controller  and update to model by delegate **/
                self.delegate.didGetFollowInfo(amountFollowing: amountFollowing, amountFollower: amountFollower)
            }))
        }
    }
     
    private func getAvatarFromAmityUserModel(amityUserModel: AmityUser) -> UIImage? {
        if let avatarAmityImageData = amityUserModel.getAvatarInfo() {
            return getAvatarFromAmityImageData(avatarAmityImageData: avatarAmityImageData)
        }
        
        return nil
    }
    
    private func getAvatarFromAmityImageData(avatarAmityImageData: AmityImageData) -> UIImage? {
        let imageURL = URL(string: avatarAmityImageData.fileURL)
        if let imageData = try? Data(contentsOf: imageURL!) {
            return UIImage(data: imageData)
        }
        
        return nil
    }

    func searchUserByDisplayName(_ displayName: String) {
        print(#"Start search users by display name -> "\#(displayName)""#)
        tokenResult.append(userRepository.searchUser(displayName, sortBy: .displayName).observe({ amityUserModelCollection, change, error in
            print(#"Search users by display name -> "\#(displayName)" Completed"#)
            if let currentError = error {
                print(currentError.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    let listFoundedAmityUserModel = amityUserModelCollection.allObjects()
                    print(#"Result search users by display name -> "\#(displayName)" : \#(listFoundedAmityUserModel.count)"#)
                    
                    let listFoundedUserModel: [UserModel] = listFoundedAmityUserModel.map { amityUserModel in
                        return UserModel(userID: amityUserModel.userId, displayname: amityUserModel.displayName ?? amityUserModel.userId)
                    }
                    
                    self.delegate.didSearchUserByDisplayName(listUserModel: listFoundedUserModel)
                }
            }
        }))
    }
    
    func setNewAvatar(imagePathURL: URL) {
        /** Show progress pop up **/
        let progressPopup = Utilities.UI.showProgressPopup(recentViewController: delegate as! UIViewController)

        /** Upload image from path to Amity **/
        fileRepository.uploadImage(with: imagePathURL, isFullImage: true) { progressPercent in

            /** Update progress bar **/
            progressPopup.message = String(format: "%.0f", progressPercent * 100) + "%"
            
        } completion: { recentUploadAmityImageData, error in
            
            if let currentError = error {
                /** Dismiss progress pop up **/
                progressPopup.dismiss(animated: true)
                
                /** Show pop up error **/
                Utilities.UI.showAlertPopup(title: "Can't change avatar", detail: currentError.localizedDescription, type: .OK, recentViewController: self.delegate as! UIViewController)
                
            } else {
                /** Send new avatar to delegate **/
                self.delegate.didSetNewAvatar(newImage: self.getAvatarFromAmityImageData(avatarAmityImageData: recentUploadAmityImageData!)!)
                
                /** Update progress bar to 100% **/
                progressPopup.message = "100%"
                
                /** Create update user builder **/
                let builder = AmityUserUpdateBuilder()
                builder.setAvatar(recentUploadAmityImageData)
                
                self.client?.updateUser(builder, completion: { isSuccess, error in

                    if let currentError = error {
                        print(currentError.localizedDescription)
                    } else {

                        /** Dismiss progress pop up **/
                        progressPopup.dismiss(animated: true)
                    }
                })
            }
        }
    }
    
    func setNewDisplayName(to displayname: String) {
        /** Create update user builder **/
        let builder = AmityUserUpdateBuilder()
        builder.setDisplayName(displayname)
        
        client?.updateUser(builder, completion: { isSuccess, error in
            if let currentError = error {
                print(currentError.localizedDescription)
            } else {
                print(#"Change displayname to "\#(displayname)" success : \#(isSuccess)"#)
            }
        })
    }
    
    func followOrUnFollowUser(to otherUserID: String, isFollow: Bool) {
        let followerManger = userRepository.followManager
        
        if isFollow {
            followerManger.followUser(withUserId: otherUserID) { isSuccess, amityFollowResponse, error in
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    print("Follow user ID : \(otherUserID) success : \(isSuccess)")
                    self.delegate.didFollowOrUnFollowUser(isFollow: true)
                }
            }
        } else {
            followerManger.unfollowUser(withUserId: otherUserID) { isSuccess, amityFollowResponse, error in
                if let currentError = error {
                    print(currentError.localizedDescription)
                } else {
                    print("Unfollow user ID : \(otherUserID) success : \(isSuccess)")
                    self.delegate.didFollowOrUnFollowUser(isFollow: false)
                }
            }
        }
    }
    
    func checkCurrentLoginedUserIsFollowUser(otherUserID: String) {
        let followerManger = userRepository.followManager
        let myFollowing = followerManger.getMyFollowingList(with: .accepted)
        var isFollow = false
        
        print("checkCurrentLoginedUserIsFollowUser \(otherUserID)")
        tokenResult.append(myFollowing.observe { amityFollowRelationShipCollection, change, error in
            let listAmityFollowRelationShip = amityFollowRelationShipCollection.allObjects()
            for data in listAmityFollowRelationShip {
                if data.targetUserId == otherUserID {
                    isFollow = true
                }
            }
            
            self.delegate.didCheckCurrentLoginedUserIsFollowUser(isFollow: isFollow)
        })
    }
    
    func autoAcceptAllFollowingRequest() {
        let followManager = userRepository.followManager
        let myFollowing = followManager.getMyFollowingList(with: .pending)
        
        tokenResult.append(myFollowing.observe({ amityFollowRelationshipCollection, change, error in
            let listFollowRelationShip = amityFollowRelationshipCollection.allObjects()
            for relationship in listFollowRelationShip {
                print("User ID \(relationship.targetUserId) following request to you")
                followManager.acceptUserRequest(withUserId: relationship.targetUserId) { isSuccess, response, error in
                    if let currentError = error {
                        print(currentError.localizedDescription)
                    } else {
                        print("Auto accept user ID \(relationship.targetUserId) following request success : \(isSuccess)")
                    }
                }
            }
        }))
    }
}

protocol UserManagerDelegate {
    func didGetUserModelByUserID(userModel: UserModel)
    func didGetCurrentLoginedUserModel(userModel: UserModel)
    func didSearchUserByDisplayName(listUserModel: [UserModel])
    func didSetNewAvatar(newImage: UIImage)
    func didFollowOrUnFollowUser(isFollow: Bool)
    func didGetFollowInfo(amountFollowing: Int, amountFollower: Int)
    func didCheckCurrentLoginedUserIsFollowUser(isFollow: Bool)
}
