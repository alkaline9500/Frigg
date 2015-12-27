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
    var holdTime = 0.0
    var currentBlue = 0.0 {
        didSet {
            garageButton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: CGFloat(currentBlue), alpha: 1.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton()
        resetTimer()
        garageButton.addTarget(self, action: "didDownButton:", forControlEvents: UIControlEvents.TouchDown)
        garageButton.addTarget(self, action: "didReleaseButton:", forControlEvents: UIControlEvents.TouchUpInside)
        garageButton.addTarget(self, action: "didReleaseButton:", forControlEvents: UIControlEvents.TouchUpInside)
        updateAuthButtonText()
    }
    
    // MARK: Button Actions
    
    @IBAction func setAuthKey(sender: UIButton) {
        authKeyButton.enabled = false
        if manager.apiKey == nil {
            manager.requestAccess(updateAuthButton)
        }
        else {
            manager.resetKey(updateAuthButton)
        }
    }
    
    func didDownButton(sender: UIButton) {
        if colorTimer == nil {
            colorTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "incrementColor", userInfo: nil, repeats: true)
        }
    }

    func didReleaseButton(sender: UIButton) {
        resetButton()
        resetTimer()
    }
    
    func incrementColor() {
        if holdTime <= 0.0 {
            resetTimer()
            garageButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            self.statusLabel.text = "..."
            self.garageButton.enabled = false
            manager.toggleGarage { response in
                self.garageButton.enabled = true
                self.updateFromResponse(response)
                self.resetButton()
            }
            return
        }
        currentBlue += 0.05
        holdTime -= 0.1
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
    
    private func resetButton() {
        currentBlue = 0.0
        garageButton.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    private func resetTimer() {
        colorTimer?.invalidate()
        colorTimer = nil
        holdTime = 3.0
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

