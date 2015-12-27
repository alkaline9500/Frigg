//
//  ViewController.swift
//  Frigg
//
//  Created by Nicolas Manoogian on 12/22/15.
//  Copyright © 2015 Nicolas Manoogian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var authKeyButton: UIButton!
    @IBOutlet weak var garageButton: UIButton!
    
    let manager = ValhallaAPIManager()
    
    var colorTimer: NSTimer? = nil
    var percentDone = 0.0
    var currentBlue = 0.0 {
        didSet {
            garageButton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: CGFloat(currentBlue), alpha: 1.0)
        }
    }
    
    struct Constants {
        static let PercentStep = 0.03
        static let ButtonCornerRadiusScale: CGFloat = 0.5
        static let BlueScaler = 0.8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetTimer()
        updateButtonColor()
        if manager.apiKey == nil {
            statusLabel.text = "Request an API key."
        }
        garageButton.addTarget(self, action: "didDownButton:", forControlEvents: UIControlEvents.TouchDown)
        garageButton.addTarget(self, action: "didReleaseButton:", forControlEvents: UIControlEvents.TouchUpInside)
        garageButton.addTarget(self, action: "didReleaseButton:", forControlEvents: UIControlEvents.TouchUpInside)
        garageButton.layer.cornerRadius = garageButton.layer.frame.size.height * Constants.ButtonCornerRadiusScale
        garageButton.clipsToBounds = true
        
        updateAuthButtonText()
    }
    
    // MARK: Button Actions
    
    @IBAction func setAuthKey(sender: UIButton) {
        authKeyButton.enabled = false
        if manager.apiKey == nil {
            // Request access
            manager.requestAccess(updateAuthButton)
        }
        else {
            // Reset key
            let alertController = UIAlertController(title: "Reset Key?", message: "Once you reset your key, you'll need to request a new one to access the server.", preferredStyle: .Alert)
            
            let resetAction = UIAlertAction(title: "Reset", style: .Destructive) { _ in
                self.manager.resetKey(self.updateAuthButton)
            }
            alertController.addAction(resetAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
                self.authKeyButton.enabled = true
            }
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func didDownButton(sender: UIButton) {
        if colorTimer == nil {
            colorTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "incrementColor", userInfo: nil, repeats: true)
        }
    }

    func didReleaseButton(sender: UIButton) {
        resetTimer()
        updateButtonColor()
    }
    
    func incrementColor() {
        if percentDone >= 1.0 {
            resetTimer()
            garageButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            self.statusLabel.textColor = UIColor.blackColor()
            self.statusLabel.text = "..."
            self.garageButton.enabled = false
            manager.toggleGarage { response in
                self.garageButton.enabled = true
                self.updateFromResponse(response)
                self.updateButtonColor()
            }
            return
        }
        percentDone += Constants.PercentStep
        updateButtonColor()
    }
    
    // MARK: Helper Methods
    
    private func updateAuthButton(response: ValhallaAPIResponse) {
        updateFromResponse(response)
        authKeyButton.enabled = true
        updateAuthButtonText()
    }
    
    private func updateFromResponse(response: ValhallaAPIResponse) {
        switch response {
        case .ConnectionError:
            self.statusLabel.textColor = UIColor.redColor()
            self.statusLabel.text = "Connection error."
        case .NoAPIKey:
            self.statusLabel.textColor = UIColor.blackColor()
            self.statusLabel.text = "Request an API key."
        case .ServerError:
            self.statusLabel.textColor = UIColor.redColor()
            self.statusLabel.text = "Server error."
        case let .Success(data: data):
            self.statusLabel.textColor = UIColor.blackColor()
            self.statusLabel.text = data
        case let .Failure(reason: reason):
            self.statusLabel.textColor = UIColor.redColor()
            self.statusLabel.text = reason
        }
    }
    
    private func updateButtonColor() {
        currentBlue = percentDone * Constants.BlueScaler
    }
    
    private func resetTimer() {
        colorTimer?.invalidate()
        colorTimer = nil
        percentDone = 0.0
    }
    
    private func updateAuthButtonText() {
        if manager.apiKey != nil {
            self.authKeyButton.setTitle("Reset Key", forState: .Normal)
        }
        else {
            self.authKeyButton.setTitle("Request Access", forState: .Normal)
        }
    }
}

