//
//  Utility.swift
//  Frigg
//
//  Created by Nicolas Manoogian on 12/27/15.
//  Copyright © 2015 Nicolas Manoogian. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}