//
//  ViewController.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-02-29.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Turn off pesky autocorrect for email field
        emailTextField.autocorrectionType = UITextAutocorrectionType.No
    }

    // MARK: - Actions
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        // Make sure we've got text in username/password
        guard let username = emailTextField.text where !username.isEmpty, let password = passwordTextField.text where !password.isEmpty else {
            displayError("Username and password are required!");
            return
        }
        
        UdacityClient.sharedInstance().authenticateWithUsernameAndPassword(username, password: password) { (success, error) in
            if success {
                self.completeLogin()
            } else {
                var errorString = "Sorry, there was a network error";
                
                if (error?.code == 403) {
                   errorString = "Sorry, your username or password were incorrect"
                }
                
                self.displayError(errorString)
            }
        }
    }
    
    
    // MARK: - Helpers
    /* Complete login */
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()) {
            // Show the main tab bar controller
            self.performSegueWithIdentifier("showTabBarViewController", sender: self)
        }
    }
}

