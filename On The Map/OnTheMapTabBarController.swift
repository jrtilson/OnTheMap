//
//  OnTheMapTabBarController.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-01.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import UIKit

class OnTheMapTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    /* Handle logout */
    @IBAction func logoutButtonTapped(sender: UIBarButtonItem) {
        UdacityClient.sharedInstance().deleteSession() { (success, error) in
            if success {
                self.completeLogout()
            } else {
                self.displayError(error?.localizedDescription)
            }
        }
    }
    
    /* Add pin button */
    @IBAction func addPinButtonTapped(sender: UIBarButtonItem) {
    }
    
    /* Refresh button */
    @IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
        if let viewController = self.selectedViewController as! MapViewController? {
            viewController.loadStudentInformation()
        } else if let viewController = self.selectedViewController as! ListViewController? {
            
        }
    }
    
    // MARK: - Helpers
    
    /* Complete logout */
    func completeLogout() {
        dispatch_async(dispatch_get_main_queue()) {
            // Show the login view controller
            self.navigationController?.performSegueWithIdentifier("showLoginViewController", sender: self)
        }
    }
    
    /* Display an error message in an alert */
    func displayError(errorMessage: String?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Error", message: errorMessage!, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
