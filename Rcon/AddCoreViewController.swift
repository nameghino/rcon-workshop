//
//  AddCoreViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/28/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

class AddCoreViewController: UIViewController {

    @IBOutlet weak var coreDescriptionTextField: UITextField!
    @IBOutlet weak var coreIdTextField: UITextField!
    @IBOutlet weak var coreAuthTokenTextField: UITextField!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptButton.addTarget(self, action: "acceptButtonTapped:", forControlEvents: .TouchUpInside)
        cancelButton.addTarget(self, action: "cancelButtonTapped:", forControlEvents: .TouchUpInside)
        
        coreDescriptionTextField.text = "mariano's core"
        coreIdTextField.text = CORE_ID
        coreAuthTokenTextField.text = AUTH_TOKEN
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func acceptButtonTapped(sender: UIButton!) {
        SharedSparkCoreManager.addCore(
            coreDescriptionTextField.text,
            coreId: coreIdTextField.text,
            authToken: coreAuthTokenTextField.text)
        
        self.cancelButtonTapped(sender)
    }
    
    func cancelButtonTapped(sender: UIButton!) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
}
