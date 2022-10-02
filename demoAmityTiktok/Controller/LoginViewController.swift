//
//  ViewController.swift
//  amityTiktok
//
//  Created by Thanaphat Thanawatpanya on 14/9/2565 BE.
//

import UIKit
import AmitySDK

class LoginViewController: UIViewController {

    @IBOutlet weak var userId: UITextField!
    
    var currentAmityClient: AmityClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /** Check amity client **/
        if currentAmityClient == nil {
            if let newConnectedClient = Utilities.Amity.getConnectedClient() {
                currentAmityClient = newConnectedClient
            }
        }
        /** Hidden navigation bar **/
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let userName = userId.text {
            if let client = currentAmityClient {
                client.login(userId: userName, displayName: nil, authToken: nil) { success, error in
                    if let e = error {
                        print("Error Register / Login user : \(e.localizedDescription)")
                        Utilities.UI.showAlertPopup(title: "Can't Login", detail: e.localizedDescription, type: .OK, recentViewController: self)
                    } else {
                        print("Register / Login user \(userName) success | Go to feed view")
                        self.performSegue(withIdentifier: "loginToFeed", sender: self)
                    }
                }
            }
        }
    }
}

