//
//  CreatePostViewController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 25/9/2565 BE.
//

import UIKit
import AmitySDK
import AVFoundation

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var videoThumbnailPreview: UIImageView!
    
    var currentAmityClient: AmityClient!
    var videoPathURL: URL!
    private var feedManager: FeedManager!
    
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
        
        /** Set delegate **/
        captionTextField.delegate = self
        
        /** Init Manager **/
        feedManager = FeedManager(amityClient: currentAmityClient, delegate: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /** Set video thumbnail to preview **/
        setVideoThumbnail()
    }
    

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        /** Show alert pop up for confirm discard post **/
        Utilities.UI.showAlertPopup(title: "Discard your post.", detail: "Are you sure to discard your post ?", type: .YES_NO, recentViewController: self)
    }

    @IBAction func postPressed(_ sender: UIButton) {
        /** Get caption on post **/
        let caption = captionTextField.text!
        
        /** Create new video post with caption **/
        feedManager.createNewVideoPost(videoPathURL: videoPathURL, caption: caption)
    }
    
    func setVideoThumbnail() {
        if let currentVideoPathURL = videoPathURL {
            let asset = AVAsset(url: currentVideoPathURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let cgImage = try! imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            videoThumbnailPreview.image = thumbnail
        }
    }
}

extension CreatePostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionTextField.endEditing(true) // Dismiss keyboard
        return true
    }
}

extension CreatePostViewController: FeedManagerDelegate {
    func didQueryFeedByUserID(listPostModel: [PostModel]) {
    }
    
    func didQueryGlobalFeed(listPostModel: [PostModel]) {
    }
    
}
