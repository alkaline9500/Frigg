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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button Actions
    
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
            self.resetTimer()
            garageButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            manager.toggleGarage { response in
                if response.success {
                    self.statusLabel.textColor = UIColor.blackColor()
                }
                else {
                    self.statusLabel.textColor = UIColor.redColor()
                }
                self.statusLabel.text = response.text
                self.resetButton()
            }
            return
        }
        currentBlue += 0.05
        holdTime -= 0.1
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

    @IBAction func setAuthKey(sender: UIButton) {
        let alertController = UIAlertController(title: "Set Authentication Key", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.text = self.manager.apiKey
        }
        
        let setKeyAction = UIAlertAction(title: "Save", style: .Default) { _ in
            guard let textField = alertController.textFields?.first else {
                assert(false, "")
            }
            self.manager.apiKey = textField.text
        }
        
        alertController.addAction(setKeyAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

