//
//  File.swift
//  Frigg
//
//  Created by Nicolas Manoogian on 12/22/15.
//  Copyright © 2015 Nicolas Manoogian. All rights reserved.
//

import Foundation
import Alamofire

enum ValhallaAPIResponse {
    case NoAPIKey
    case ConnectionError
    case ServerError
    case Failure(reason: String)
    case Success(data: String)
}

class ValhallaAPIManager {
    struct Constants {
        static let APIUrl = "https://bluefile.org/share/valhalla.php"
        static let APIKeyName = "valhalla_key"
        static let AuthorizeKeyName = "authorize"
        static let CommandKeyName = "command"
        static let SuccessKeyName = "success"
        static let ResponseTextKeyName = "response"
        static let GarageValueName = "garage"
    }
    
    var apiKey: String? = nil {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(apiKey, forKey: Constants.APIKeyName)
        }
    }
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        apiKey = defaults.stringForKey(Constants.APIKeyName)
    }
    
    func resetKey(completion: (ValhallaAPIResponse -> Void)) {
        self.apiKey = nil
        completion(.Success(data: "Key was reset."))
        // TODO: API call to remove from server
    }
    
    func requestAccess(completion: (ValhallaAPIResponse -> Void)) {
        let parameters = [
            Constants.AuthorizeKeyName : 1
        ]

        Alamofire.request(.POST, Constants.APIUrl, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil)
            .responseJSON { response in
                // Check connection
                guard response.result.error == nil else {
                    completion(.ConnectionError)
                    return
                }
                
                // Check JSON
                guard let responseJSON = response.result.value as? NSDictionary else {
                    completion(.ServerError)
                    return
                }
                
                // Check success
                guard responseJSON[Constants.SuccessKeyName] as? Bool == true else {
                    completion(.ServerError)
                    return
                }
                
                // Check new key
                guard let newAPIKey = responseJSON[Constants.APIKeyName] as? String else {
                    completion(.ServerError)
                    return
                }
                
                // Check response
                guard let serverResponseText = responseJSON[Constants.ResponseTextKeyName] as? String else {
                    completion(.ServerError)
                    return
                }

                // Update key
                self.apiKey = newAPIKey
                completion(.Success(data: serverResponseText))
        }
    }

    
    func toggleGarage(completion: (ValhallaAPIResponse -> Void)) {
        guard let apiKey = apiKey else {
            completion(ValhallaAPIResponse.NoAPIKey)
            return
        }
        
        let parameters = [
            Constants.APIKeyName : apiKey,
            Constants.CommandKeyName : Constants.GarageValueName
        ]
        
        Alamofire.request(.POST, Constants.APIUrl, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil)
        .responseJSON { response in
            // Check connection
            guard response.result.error == nil else {
                completion(.ConnectionError)
                return
            }
            
            // Check JSON
            guard let responseJSON = response.result.value as? NSDictionary else {
                completion(.ServerError)
                return
            }
            
            // Check response text
            guard let serverResponseText = responseJSON[Constants.ResponseTextKeyName] as? String else {
                completion(.ServerError)
                return
            }
            
            // Check success
            guard let success = responseJSON[Constants.SuccessKeyName] as? Bool else {
                completion(.ServerError)
                return
            }
            
            // Call completion
            if success {
                completion(.Success(data: serverResponseText))
            }
            else {
                completion(.Failure(reason: serverResponseText))
            }
        }
    }
}