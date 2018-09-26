//
//  LoginViewController.swift
//  CKUsersiOS21
//
//  Created by John Tate on 9/26/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(segueToWelcomeVC), name: UserController.shared.currentUserWasSetNotification, object: nil)
    }
    
    @objc func segueToWelcomeVC() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toWelcomeVC", sender: self)
        }
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text,
            let username = usernameTextField.text,
            !email.isEmpty, !username.isEmpty else { return }
        
        activityIndicator.startAnimating()
        
        UserController.shared.createUserWith(username: username, email: email) { (success) in
            
            if success {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    self.presentAlertControllerWith(title: "Whoops--Something Went Wrong", message: "Please make sure you are logged into iCloud in your phone settings.")
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        
        guard UserController.shared.currentUser == nil else {
            segueToWelcomeVC()
            return
        }
        self.activityIndicator.startAnimating()
        
        // if not a current user, then fetch
        UserController.shared.fetchCurrentUser { (success) in
            
            if !success {
                DispatchQueue.main.async {
                    self.presentAlertControllerWith(title: "No iCloud Account configured", message: "Please sign into your iCloud")
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}
