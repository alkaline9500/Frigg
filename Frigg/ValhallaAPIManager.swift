//
//  File.swift
//  Frigg
//
//  Created by Nicolas Manoogian on 12/22/15.
//  Copyright © 2015 Nicolas Manoogian. All rights reserved.
//

import Foundation
import Alamofire

struct ValhallaAPIResponse {
    let success: Bool
    let text: String
}

class ValhallaAPIManager {
    struct Constants {
        static let APIUrl = "https://bluefile.org/share/valhalla.php"
        static let APIKeyName = "valhalla_key"
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

    
    func toggleGarage(completion: (ValhallaAPIResponse -> Void)) {
        guard let apiKey = apiKey else {
            let valhallaResponse = ValhallaAPIResponse(success: false, text: "No authentication key is set.")
            completion(valhallaResponse)
            return
        }
        
        let parameters = [
            Constants.APIKeyName : apiKey,
            Constants.CommandKeyName : Constants.GarageValueName
        ]
        
        Alamofire.request(.POST, "https://bluefile.org/share/valhalla.php", parameters: parameters, encoding: ParameterEncoding.URL, headers: nil)
        .responseJSON { response in
            // Check connection
            guard response.result.error == nil else {
                let valhallaResponse = ValhallaAPIResponse(success: false, text: "Can't connect, check connection.")
                completion(valhallaResponse)
                return
            }
            
            // Check JSON
            guard let responseJSON = response.result.value as? NSDictionary else {
                let valhallaResponse = ValhallaAPIResponse(success: false, text: "Bad server data.")
                completion(valhallaResponse)
                return
            }
            
            // Check response text
            var responseText = "Server OK."
            if let serverResponseText = responseJSON[Constants.ResponseTextKeyName] as? String {
                responseText = serverResponseText
            }
            
            guard let success = responseJSON[Constants.SuccessKeyName] as? Bool else {
                let valhallaResponse = ValhallaAPIResponse(success: false, text: "Bad server data.")
                completion(valhallaResponse)
                return
            }
            
            // Call completion
            let valhallaResponse = ValhallaAPIResponse(success: success, text: responseText)
            completion(valhallaResponse)
        }
    }
}