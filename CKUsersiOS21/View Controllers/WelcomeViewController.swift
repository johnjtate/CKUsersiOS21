//
//  WelcomeViewController.swift
//  CKUsersiOS21
//
//  Created by John Tate on 9/26/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // by the time this view loads, you know you have a current user
        guard let currentUser = UserController.shared.currentUser else { return }
        welcomeLabel.text = "Welcome \(currentUser.username)"
    }
}
