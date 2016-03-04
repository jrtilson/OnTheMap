//
//  PostViewController.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-03.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PostViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var locationSearchTextInput: UITextField!
    @IBOutlet weak var linkTextInput: UITextField!
    @IBOutlet weak var findLocationView: UIView!
    @IBOutlet weak var mapPostLocationView: UIView!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Properties
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    let regionRadius: CLLocationDistance = 1000
    
    let locationDefaultText = "Enter your location here"
    let linkDefaultText = "Enter a link here"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add close button to nav bar
        navBarItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "closeTapped")
        
        // Set text field delegates
        locationSearchTextInput.delegate = self
        linkTextInput.delegate = self
        
        // Set default text
        locationSearchTextInput.text = locationDefaultText
        linkTextInput.text = linkDefaultText
        
        // Add a gesture recognizer to look for taps, to close the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Set a background for the submit button
        submitButton.backgroundColor = UIColor.lightGrayColor()
        
        // Disable autocorrect on link input
        linkTextInput.autocorrectionType = UITextAutocorrectionType.No
    }
    
    // MARK: - Actions
    func closeTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findButtonTapped(sender: UIButton) {
        // Show a wait overlay
        showWaitOverlay()
        if let text = locationSearchTextInput.text {
            if !text.isEmpty && text != locationDefaultText {
                forwardGeocoding(text) {
                    (latitude, longitude, error) in
                    
                    // Hide all overlays when we're done attempting to geocode
                    self.removeAllOverlays()
                    
                    if let error = error {
                        self.displayError("Sorry, couldn't find that location.")
                        print(error)
                    } else {
                        self.latitude = latitude
                        self.longitude = longitude
                        self.loadMapPostView()
                    }
                }
            }
        }
    }
    
    /* Submit button tapped */
    @IBAction func submitButtonTapped(sender: UIButton) {
        
        let udacityClient = UdacityClient.sharedInstance()
        
        // Check for media URL
        if let mediaURL = linkTextInput.text {
            if mediaURL != linkDefaultText && !mediaURL.isEmpty {
                // Build a StudentInformation Struct
                let studentInfo = StudentInformation(uniqueKey: udacityClient.userID!, firstName: udacityClient.firstName!, lastName: udacityClient.lastName!, latitude: Double(latitude!), longitude: Double(longitude!), mediaURL: mediaURL, mapString:   locationSearchTextInput.text!)
                
                ParseClient.sharedInstance().postStudentLocation(studentInfo) {
                    (success, error) in
                
                    if let error = error {
                        self.displayError(error.localizedDescription)
                    } else {
                        // Success.. close the modal
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    /* Attemp to geocode a given string */
    func forwardGeocoding(address: String, completionHandler: (latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, error: NSError?) -> Void) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                completionHandler(latitude: nil, longitude: nil, error: error)
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                completionHandler(latitude: coordinate?.latitude, longitude: coordinate?.longitude, error: nil)
            }
        })
    }
    
    func loadMapPostView() {
        findLocationView.hidden = true
        mapPostLocationView.hidden = false
        
        // Set location for setting the map region
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        // Set coordinate to add an annotation to the map
        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        
        // Create annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        // Add annotation to map
        locationMapView.addAnnotation(annotation)
        
        // Center and zoom in on the location
        centerMapOnLocation(location)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        locationMapView.setRegion(coordinateRegion, animated: true)
    }
    
    /* Called when a tap is recognized */
    func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == locationSearchTextInput {
            if textField.text!.isEmpty {
                textField.text = locationDefaultText
            }
        } else if textField == linkTextInput {
            if textField.text!.isEmpty {
                textField.text = linkDefaultText
            }
        }
    }
    
}
