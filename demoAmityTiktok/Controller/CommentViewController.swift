//
//  CommentViewController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 20/9/2565 BE.
//

import UIKit
import AmitySDK

class CommentViewController: UIViewController {
    
    /** UI Element linked to XIB **/
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!

    private var comments: [CommentModel] = []
    private var commentManager: CommentManager!
    var currentAmityClient: AmityClient!
    var postID: String!
    
    /** Delegate **/
    var commentViewDelegate: CommentViewControllerDelegate?
    
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
        commentTableView.dataSource = self
        commentTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentTableViewCell")
        commentTextField.delegate = self
        
        /** Init manager **/
        commentManager = CommentManager(amityClient: currentAmityClient, delegate: self)
        
        /** Load comments **/
        loadComments()
    }
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        /** Send back to feed view controller for delete comment view controller **/
        commentViewDelegate?.pressDismissButton(viewController: self)
    }
    
    
    @IBAction func sendCommentPressed(_ sender: UIButton) {
        /** Create new comment to post with post id **/
        if let currentPostID = postID, let newCommentDetail = commentTextField.text {
            commentManager.createNewComment(currentPostID, detail: newCommentDetail)
            commentTextField.text = ""
        }
    }
    
    func loadComments() {
        /** Query comment by post ID **/
        if let currentPostID = postID {
            commentManager.queryCommentByPostID(currentPostID)
        }
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
    func didPressAvatarOrDisplayName(comment: CommentModel) {
        /** Get profile view controller by storyboard id **/
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        
        /** Set user and amity client to comment view controller **/
//        vc.user = comment.owner
        vc.selectedUserID = comment.owner.userID
        
        /** Go to profile view controller **/
        navigationController?.pushViewController(vc, animated: true)
        
        /** Send back to feed view controller for delete comment view controller **/
        commentViewDelegate?.pressDismissButton(viewController: self)
    }
}

extension CommentViewController: CommentManagerDelegate {
    func didCommentUpdated() {
    }
    
    func didQueryCommentByPostID(newListComment: [CommentModel]) {
        /** Set new list comment from query **/
        comments = newListComment
        
        /** Reload comment **/
        commentTableView.reloadData()
    }
}

extension CommentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextField.endEditing(true)
        return true
    }
}

extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "commentTableViewCell", for: indexPath) as! CommentTableViewCell
        let commentData = comments[indexPath.row]
        
        cell.configure(commentModel: commentData, manager: commentManager, vc: self)
    
        return cell
    }
}

protocol CommentViewControllerDelegate {
    func pressDismissButton(viewController: UIViewController)
}
