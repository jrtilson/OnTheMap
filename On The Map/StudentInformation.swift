//
//  StudentInformation.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-01.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    // MARK: - Struct Properties
    var latitude: Double
    var longitude: Double
    var firstName: String
    var lastName: String
    var mediaURL: String
    var uniqueKey: String
    var mapString: String
 
    // Static var to hold an array of StudentInformation structs for the app
    static var Students: [StudentInformation] = [StudentInformation]()
    
    // MARK: - Init
    /* Construct StudentInformation struct from dictionary */
    init(dictionary: [String : AnyObject]) {
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
    }
    
    /* Construct StudentInformation struct with values */
    init(uniqueKey: String, firstName: String, lastName: String, latitude: Double, longitude: Double, mediaURL: String, mapString: String) {
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mediaURL = mediaURL
        self.mapString = mapString
    }
    
    // MARK: - Helpers    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func infoFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var info = [StudentInformation]()
        
        for result in results {
            info.append(StudentInformation(dictionary: result))
        }
        
        return info
    }
}