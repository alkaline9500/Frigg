//
//  UIColor+Interpolated.swift
//  Frigg
//
//  Created by Nicolas Manoogian on 12/27/15.
//  Copyright © 2015 Nicolas Manoogian. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorFromInterpolation(startColor: UIColor, endColor: UIColor, percent: CGFloat, adjustment: (CGFloat -> CGFloat)) -> UIColor {
        let adjustedPercent = adjustment(percent)
        
        var startRed: CGFloat = 0.0
        var startGreen: CGFloat = 0.0
        var startBlue: CGFloat = 0.0
        var startAlpha: CGFloat = 0.0
        
        var endRed: CGFloat = 0.0
        var endGreen: CGFloat = 0.0
        var endBlue: CGFloat = 0.0
        var endAlpha: CGFloat = 0.0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        let newRed = (1.0 - adjustedPercent) * startRed + adjustedPercent * endRed
        let newGreen = (1.0 - adjustedPercent) * startGreen + adjustedPercent * endGreen
        let newBlue = (1.0 - adjustedPercent) * startBlue + adjustedPercent * endBlue
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: endAlpha)
    }
}