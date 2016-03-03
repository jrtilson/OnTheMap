//
//  MapViewController.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-01.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudentInformation()
    }
    
    // MARK: - MKMapViewDelegate

    // Add a rightCalloutAccessoryView so we can use it to respond to tap events
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                
                var openURL: NSURL
                
                // Make sure our url has no spaces
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
    }
    
    // MARK: - Helpers
    
    /* Helper function that calls the ParseClient to load student information */
    func loadStudentInformation() {
        ParseClient.sharedInstance().getStudentLocations(100, skip: nil, order: "-updatedAt") {(studentInfo, error) in
            if let studentInfo = studentInfo {
                StudentInformation.Students = studentInfo
                self.populateMap()
                print("Loading Student Information")
            } else {
                self.displayError("Sorry, there was an error loading student information")
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
        
            for student in StudentInformation.Students {
            
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
}
