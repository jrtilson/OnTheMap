//
//  ParseClient.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-03-01.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import Foundation

class ParseClient: BaseClient {
    // MARK: - Constants
    struct Methods { // Method constants
        static let StudentLocation = "StudentLocation"
    }
    
    struct Constants {
        static let BaseURL: String = "https://api.parse.com/1/classes/"
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "FirstName"
        static let LastName = "LastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MediaURL = "mediaURL"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    
    // Class properties
    let parseHeaders = [
        "X-Parse-Application-Id": ParseClient.Constants.ParseApplicationID,
        "X-Parse-REST-API-Key": ParseClient.Constants.ParseRestAPIKey
    ]
    
    // MARK: - Init
    override init() {
        super.init()
        baseURL = Constants.BaseURL
    }
    
    // MARK: - API Actions
    
    /* Get a student locations from Parse */
    func getStudentLocations(limit: Int?, skip: Int?, order: String?, completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        let method: String = Methods.StudentLocation
        
        var parameters = [String: AnyObject]()
        
        // Check for optional parameters
        if let limit = limit as Int! {
            parameters[ParseClient.ParameterKeys.Limit] = limit
        }
        
        if let skip = skip as Int! {
            parameters[ParseClient.ParameterKeys.Skip] = skip
        }
        
        if let order = order as String! {
            parameters[ParseClient.ParameterKeys.Order] = order
        }
        
        performGET(method, parameters: parameters, additionalHTTPHeaders: parseHeaders) {JSONResult, error in
            if let error = error {
                print(error)
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult[ParseClient.JSONResponseKeys.Results] as? [[String : AnyObject]] {
                    let info = StudentInformation.infoFromResults(results)
                    completionHandler(result: info, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }

    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}