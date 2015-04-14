//
//  AddCoreViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/28/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

struct HardcodedCoreData {
    let d: String
    let id: String
    let t: String
}

let GLBCORE3 = HardcodedCoreData(
    d: "c3",
    id: "55ff71065075555338581687",
    t: "4ed8196934ddcddb658bb894ed0faea1718466ca"
)

let GLBCORE_DOOR = HardcodedCoreData(
    d: "door",
    id: "55ff71065075555353261887",
    t: "4ed8196934ddcddb658bb894ed0faea1718466ca"
)

let GLBCORE2 = HardcodedCoreData(d: "zapatilla", id: "53ff75065075535155461187", t: "4ed8196934ddcddb658bb894ed0faea1718466ca")

let SELECTED_CORE = GLBCORE2

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
        
        coreDescriptionTextField.text = SELECTED_CORE.d
        coreIdTextField.text = SELECTED_CORE.id
        coreAuthTokenTextField.text = SELECTED_CORE.t
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func acceptButtonTapped(sender: UIButton!) {
        NSLog("accept tapped")
        SharedSparkCoreManager.addCore(
            coreDescriptionTextField.text,
            coreId: coreIdTextField.text,
            authToken: coreAuthTokenTextField.text)
        self.performSegueWithIdentifier(kCoresViewControllerUnwindFromDoneIdentifier, sender: nil)
    }
    
    func cancelButtonTapped(sender: UIButton!) {
        NSLog("cancel tapped")
        self.performSegueWithIdentifier(kCoresViewControllerUnwindFromCancelIdentifier, sender: nil)
    }

    
    
}
