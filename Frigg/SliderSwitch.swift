//
//  SliderSwitch.swift
//  Frigg
//
//  Created by Nicolas Manoogian on 12/27/15.
//  Copyright © 2015 Nicolas Manoogian. All rights reserved.
//

import UIKit

enum SliderSwitchState {
    case Unlatched, Latched, Error
}

class SliderSwitch: UIView {

    struct Constants {
        static let PinColorScaler: CGFloat = 0.8
        static let PinSizeScaler: CGFloat = 0.9
        static let ButtonCornerRadiusScale: CGFloat = 0.5
        static let PinResetDuration: NSTimeInterval = 0.2
    }

    private let pinView: UIView
    private let panGestureRecognizer: UIPanGestureRecognizer
    private var pinXOrigin: CGFloat = 0.0
    private var stateColorMap: [SliderSwitchState : UIColor]
    
    var onLatch: (Void -> Void)?
    var isPanning = false
    var enabled = true
    var state = SliderSwitchState.Unlatched
    
    var percentDragged: CGFloat = 0.0 {
        didSet {
            let maxPossible = frame.size.width - pinView.frame.size.width - 2.0*pinXOrigin
            var newPinFrame = pinView.frame
            newPinFrame.origin.x = maxPossible*percentDragged + pinXOrigin
            pinView.frame = newPinFrame
            
            setInterpolatedColor(colorForState(.Unlatched), endColor: colorForState(.Latched), percent: percentDragged)
        }
    }
    var isLatched: Bool {
        set(isLatched) {
            percentDragged = isLatched ? 1.0 : 0.0
        }

        get {
            return percentDragged == 1.0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        pinView = UIView()
        panGestureRecognizer = UIPanGestureRecognizer()
        stateColorMap = [
            .Unlatched : UIColor.blueColor(),
            .Latched : UIColor.greenColor(),
            .Error : UIColor.redColor()
        ]
        super.init(coder: aDecoder)
        panGestureRecognizer.addTarget(self, action: "didPanPin:")
        pinView.addGestureRecognizer(panGestureRecognizer)

        if let backgroundColor = backgroundColor {
            setColor(backgroundColor, forState: .Unlatched)
            updateColor()
        }

        addSubview(pinView)
    }
    
    func setColor(color: UIColor, forState: SliderSwitchState) {
        stateColorMap[state] = color
    }
    
    private func colorForState(state: SliderSwitchState) -> UIColor {
        guard let currentColor = stateColorMap[state] else {
            assertionFailure("No color set for state: " + stateColorMap.description)
            return UIColor.blackColor()
        }
        return currentColor
    }
    
    private func updateColor() {
        setColor(colorForState(state))
    }
    
    private func setColor(color: UIColor) {
        backgroundColor = color
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        backgroundColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        pinView.backgroundColor = UIColor(red: red*Constants.PinColorScaler, green: green*Constants.PinColorScaler, blue: blue*Constants.PinColorScaler, alpha: alpha)
    }
    
    private func setInterpolatedColor(startColor: UIColor, endColor: UIColor, percent: CGFloat) {
        let color = UIColor.colorFromInterpolation(startColor, endColor: endColor, percent: percent) { originalPercent in
            return pow(originalPercent, 3.0)
        }
        setColor(color)
    }
    
    func didPanPin(recognizer: UIPanGestureRecognizer) {
        guard enabled else { return }
        
        switch recognizer.state {
        case .Began:
            isPanning = true
            
        case .Changed:
            let translation = recognizer.translationInView(self)
            let endBarX = frame.size.width - pinView.frame.size.width - pinXOrigin
            var newX = pinXOrigin + translation.x
            newX = max(newX, pinXOrigin)
            newX = min(newX, endBarX)
            
            let maxPossible = endBarX - pinXOrigin
            let current = newX - pinXOrigin
            percentDragged = current/maxPossible
            
        case .Cancelled:
            fallthrough
        case .Ended:
            isPanning = false
            if self.isLatched {
                enabled = false
                delay(3.0) {
                    UIView.animateWithDuration(Constants.PinResetDuration) {
                        self.percentDragged = 0.0
                    }
                    self.enabled = true
                }
                if let onLatch = self.onLatch {
                    onLatch()
                }
            }
            else {
                UIView.animateWithDuration(Constants.PinResetDuration) {
                    self.percentDragged = 0.0
                }
            }
        default: break
        }
    }
    
    override func layoutSubviews() {
        let sideLength = frame.size.height
        let pinSideLength = round(sideLength * Constants.PinSizeScaler)
        layer.cornerRadius = sideLength * Constants.ButtonCornerRadiusScale
        
        let pinStart = (sideLength - pinSideLength)/2.0
        pinXOrigin = pinStart
        
        pinView.frame = CGRect(x: pinStart, y: pinStart, width: pinSideLength, height: pinSideLength)
        pinView.layer.cornerRadius = pinSideLength * Constants.ButtonCornerRadiusScale
    }
    
}
