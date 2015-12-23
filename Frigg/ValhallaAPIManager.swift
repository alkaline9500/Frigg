//
//  File.swift
//  Frigg
//
//  Created by Nicolas Manoogian on 12/22/15.
//  Copyright © 2015 Nicolas Manoogian. All rights reserved.
//

import Foundation

class ValhallaAPIManager {
    struct Constants {
        let APIUrl = "https://bluefile.org/share/valhalla.php"
        let APIKeyName = "valhalla_key"
    }
    
    var apiKey: String? = nil
    
    func toggleGarage(completion: (Bool -> Void)) {
        // TODO: Call to API
        completion(true)
    }
}