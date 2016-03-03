//
//  ListViewController.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-01.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var studentTableView: UITableView!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudentInformation()
    }
    
    // MARK: - Table View DataSource and Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.Students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell")!
        let student = StudentInformation.Students[indexPath.row]
        
        // Set the student name and location image
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.imageView?.image = UIImage(named: "Location")
        
        return cell
    }
    
    /* Handle tap on table row to open student information media URL in a browser */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let student = StudentInformation.Students[indexPath.row]
        
        var openURL: NSURL
        
        if let toOpen = student.mediaURL as String? {
            
            if (toOpen.characters.contains(" ")) {
                displayError("Sorry, we can't open the URL: \(toOpen)")
            } else {

                // Try to force url's without a protocol prefix to have one
                if (toOpen.lowercaseString.hasPrefix("http://") || toOpen.lowercaseString.hasPrefix("https://")) {
                    openURL = NSURL(string: toOpen)!
                } else {
                    openURL = NSURL(string: "http://\(toOpen)")!
                }
            
                // Make sure we can actully open the URL
                if (app.canOpenURL(openURL)) {
                    app.openURL(openURL)
                } else {
                    displayError("Sorry, we can't open the URL: \(toOpen)")
                }
            }
        }
    }
    
    // MARK: - Helpers
    /* Helper function that calls the ParseClient to load student information */
    func loadStudentInformation() {
        ParseClient.sharedInstance().getStudentLocations(100, skip: nil, order: "-updatedAt") {(studentInfo, error) in
            if let studentInfo = studentInfo {
                StudentInformation.Students = studentInfo
                print("Loading Student Information")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentTableView.reloadData()
                }
            } else {
                self.displayError("Sorry, there was an error loading student information")
            }
        }
    }
}
