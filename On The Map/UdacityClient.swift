//
//  UdacityClient.swift
//  On The Map
//
//  Created by Jeff Tilson on 2016-02-29.
//  Copyright © 2016 Jeff Tilson. All rights reserved.
//

import Foundation

class UdacityClient: BaseClient {
    
    // MARK: - Constants
    struct Methods { // Method constants
        static let Session = "session"
        static let User = "users/{id}"
    }
    
    struct Constants {
        static let BaseURL: String = "https://www.udacity.com/api/"
    }
    
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let Session = "session"
        static let Account = "account"
        static let ID = "id"
        static let Key = "key"
    }
    
    // MARK: - Class Properties
    var sessionID : String? = nil
    var userID : String? = nil
    
    // MARK: - Init
    override init() {
        super.init()
        baseURL = Constants.BaseURL
    }
    
    // MARK: - API Actions
    
    /* Authenticate with the API using username and password */
    func authenticateWithUsernameAndPassword(username: String, password: String, completionHandler: (success: Bool, error : NSError?) -> Void) {
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let method : String = Methods.Session
        
        let jsonBody = [UdacityClient.JSONBodyKeys.Udacity: [
            UdacityClient.JSONBodyKeys.Username: username,
            UdacityClient.JSONBodyKeys.Password: password
        ]]
        
        let parameters = [String: AnyObject]()
        
        let headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        /* 2. Make the request */
        performPOST(method, parameters: parameters, jsonBody: jsonBody, additionalHTTPHeaders: headers) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandler(success: false, error: error)
            } else {
                
                // Check for session in result
                guard let session = JSONResult[UdacityClient.JSONResponseKeys.Session] as? [String: String] else {
                    completionHandler(success: false, error: NSError(domain: "no session", code: 0, userInfo: [NSLocalizedDescriptionKey: "No session in result!"]))
                    return
                }
                
                // Check for session id in result
                guard let id = session[UdacityClient.JSONResponseKeys.ID] as String! else {
                    completionHandler(success: false, error: NSError(domain: "no id", code: 0, userInfo: [NSLocalizedDescriptionKey: "No session id in result!"]))
                    return
                }

                // Check for account in result
                guard let account = JSONResult[UdacityClient.JSONResponseKeys.Account] as? [String: AnyObject] else {
                    completionHandler(success: false, error: NSError(domain: "no account", code: 0, userInfo: [NSLocalizedDescriptionKey: "No account in result!"]))
                    return
                }

                
                
                // Check for account key in result
                guard let key = account[UdacityClient.JSONResponseKeys.Key] as! String! else {
                    
                    completionHandler(success: false, error: NSError(domain: "no key", code: 0, userInfo: [NSLocalizedDescriptionKey: "No account key in result!"]))
                    return
                }
                
                self.userID = key
                self.sessionID = id
                
                completionHandler(success:true, error: nil)
            }
        }
    }
    
    /* Get user info */
   // func getUserData(
    
    /* Log user out of Udacity (delete session) */
    func deleteSession(completionHandler: (success: Bool, error: NSError?) -> Void) {
        let method: String = Methods.Session
        
        let parameters = [String: AnyObject]()
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        var headers = [String:String]()
        
        if let xsrfCookie = xsrfCookie {
            headers["X-XSRF-TOKEN"] = xsrfCookie.value
        }
        
        performDELETE(method, parameters: parameters, additionalHTTPHeaders: headers) {JSONResult, error in
            if let error = error {
                print(error)
                completionHandler(success: false, error: error)
            } else {
                guard let session = JSONResult[UdacityClient.JSONResponseKeys.Session] as? [String: String] else {
                    completionHandler(success: false, error: NSError(domain: "no session", code: 0, userInfo: [NSLocalizedDescriptionKey: "No session in result!"]))
                    return
                }

                guard let _ = session[UdacityClient.JSONResponseKeys.ID] as String! else {
                    completionHandler(success: false, error: NSError(domain: "no session id", code: 0, userInfo: [NSLocalizedDescriptionKey: "No session id in result!"]))
                    return
                }
                
                self.sessionID = nil
                self.userID = nil
                
                completionHandler(success:true, error: nil)
            }
        }
        
    }
    
    
    // MARK: - Class overrides
    
    /* Need to subset the data from Udacity API */
    override class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(newData)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}
