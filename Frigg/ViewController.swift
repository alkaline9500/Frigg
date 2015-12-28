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
    
    @IBOutlet weak var sliderSwitch: SliderSwitch!
    let manager = ValhallaAPIManager()
    
    struct Constants {
        static let PercentStep = 0.03
        static let ButtonCornerRadiusScale: CGFloat = 0.5
        static let BlueScaler = 0.8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if manager.apiKey == nil {
            statusLabel.text = "Request an API key."
        }
        sliderSwitch.onLatch = {
            self.manager.toggleGarage { response in
                self.updateFromResponse(response)
            }
        }
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
    
    // MARK: Helper Methods
    
    private func updateAuthButton(response: ValhallaAPIResponse) {
        updateFromResponse(response)
        authKeyButton.enabled = true
        updateAuthButtonText()
    }
    
    private func updateFromResponse(response: ValhallaAPIResponse) {
        switch response {
        case .ConnectionError:
            self.sliderSwitch.state = .Error
            self.statusLabel.text = "Connection error."
        case .NoAPIKey:
            self.sliderSwitch.state = .Error
            self.statusLabel.text = "Request an API key."
        case .ServerError:
            self.sliderSwitch.state = .Error
            self.statusLabel.text = "Server error."
        case let .Success(data: data):
            self.statusLabel.text = data
        case let .Failure(reason: reason):
            self.sliderSwitch.state = .Error
            self.statusLabel.text = reason
        }
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

