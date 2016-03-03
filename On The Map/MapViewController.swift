//
//  MapViewController.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-01.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    var studentInfomation: [StudentInformation] = [StudentInformation]()

    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudentInformation()
    }
    
    // MARK: - Helpers
    
    /* Helper function that calls the ParseClient to load student information */
    func loadStudentInformation() {
        ParseClient.sharedInstance().getStudentLocations(100, skip: nil, order: nil) {(info, error) in
            if let info = info {
                self.studentInfomation = info
                self.populateMap()
                print("Loading Student Information")
            } else {
                self.displayError(error?.localizedDescription)
            }
        }
    }
    
    /* Helper function to populate the MapView */
    func populateMap() {
        dispatch_async(dispatch_get_main_queue()) {
            // Remove current annotations before populating
            self.mapView.removeAnnotations(self.mapView.annotations)
        
            // Set up an array of MKPointAnnotations
            var annotations = [MKPointAnnotation]()
        
            for student in self.studentInfomation {
            
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lat = CLLocationDegrees(student.latitude)
                let long = CLLocationDegrees(student.longitude)
            
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
                let first = student.firstName
                let last = student.lastName
                let mediaURL = student.mediaURL
            
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
            
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
        
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
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
