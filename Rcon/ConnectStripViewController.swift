//
//  ConnectStripViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 4/29/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

class ConnectStripViewController: UIViewController {
    
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    
    var ftc: FirstTimeConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ssidTextField.text = FirstTimeConfig.getSSID()
        passwordTextField.text = "Gl0b4ntl4bs2015"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss() {
        map(self.presentingViewController) {
            (vc) -> Bool in
            vc.dismissViewControllerAnimated(true, completion: nil)
            return true
        }
    }
    
    @IBAction func connect(sender: UIButton) {
        self.connectButton.enabled = false
        ftc = FirstTimeConfig()
        ftc.transmitSettings()
        
        let queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        let dt = Int64(10 * NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, dt)
        dispatch_after(time, dispatch_get_main_queue()) {
            [unowned self] in
            self.ftc.stopTransmitting()
            NSLog("timeout")
        }
        
        dispatch_async(queue) {
            [unowned self] in
            NSLog("about to wait for ack... ")
            self.ftc.waitForAck()
            NSLog("stopping transmission ")
            self.ftc.stopTransmitting()
            self.connectButton.enabled = true
        }
    }
}
