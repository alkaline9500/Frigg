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
    
    let manager = ValhallaAPIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didToggleGarage(sender: UIButton) {
        manager.toggleGarage { success in
            if success {
                self.statusLabel.text = "Success"
            }
            else {
                self.statusLabel.text = "Failure"
            }
        }
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

