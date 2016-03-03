//
//  ViewHelpers.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-03.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import UIKit
import Foundation

/* Collection of helpers for view controllers */
public extension UIViewController {
    /* Display an error message in an alert */
    func displayError(errorMessage: String?) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Error", message: errorMessage!, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}