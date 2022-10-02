//
//  TiktokTabBarController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 23/9/2565 BE.
//

import UIKit
import AmitySDK

class TiktokTabBarController: UITabBarController {
    
    var currentAmityClient: AmityClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
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
    }
}

extension TiktokTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        /** Get title of button **/
        let titleSelected: String = viewController.tabBarItem.title!
        
        /** Open alert menu if tap add button **/
        if titleSelected == "" {
            Utilities.UI.createChooseMediaMenu(recentViewController: self, mediaType: .video)
        }
    }
}

extension TiktokTabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /** Get video url of library path for create post **/
        let videoPathURL = info[.mediaURL] as! URL
        
        /** Get create post view controller by storyboard id **/
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createPostVC = storyboard.instantiateViewController(withIdentifier: "createPost") as! CreatePostViewController
        
        /** Setting create post view controller **/
        createPostVC.view.isUserInteractionEnabled = true
        createPostVC.currentAmityClient = currentAmityClient
        createPostVC.videoPathURL = videoPathURL
    
        /** Go to create post view controller **/
        navigationController?.pushViewController(createPostVC, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
