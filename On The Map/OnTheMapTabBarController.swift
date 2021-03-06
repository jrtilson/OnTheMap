//
//  OnTheMapTabBarController.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-01.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import UIKit

class OnTheMapTabBarController: UITabBarController {

    // MARK: - Actions
    
    /* Post info button */
    @IBAction func postButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showPostViewController", sender: self)
    }

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
    
    /* Refresh button */
    @IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
        if self.selectedViewController!.isKindOfClass(MapViewController) {
            let vc = self.selectedViewController as! MapViewController
            vc.loadStudentInformation()
        } else  if self.selectedViewController!.isKindOfClass(ListViewController) {
            let vc = self.selectedViewController as! ListViewController
            vc.loadStudentInformation()
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
}
