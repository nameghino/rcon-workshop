//
//  AddApplianceTableViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 4/10/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit


let applianceTypes = ["blender", "fan", "fridge", "heater-horizontal", "projector", "stove", "toaster", "washing-machine"]

let kPopupSelectorViewControllerIdentifier = "PopupSelectorViewController"
let kDimmerViewTag = 25

class AddApplianceTableViewController: UITableViewController {
    
    @IBOutlet weak var applianceNameTextField: UITextField!
    var selectedCoreName: String!
    var selectedApplianceType: String!
    var selectedPin: Int!
    
    var selectorController: PopupSelectorViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(
            barButtonSystemItem: .Done,
            target: self,
            action: "createAppliance:")
        self.navigationItem.rightBarButtonItem = button
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showApplianceTypeSelector(sender: AnyObject!) {
        if let sb = self.storyboard {
            let pickerController = sb.instantiateViewControllerWithIdentifier(kPopupSelectorViewControllerIdentifier) as! PopupSelectorViewController
            pickerController.options = applianceTypes
            pickerController.titleText = "Select the appliance type"
            pickerController.onDismissBlock = {
                [unowned self](index, option) -> () in
                NSLog("appliance type selected: \(option)")
                self.selectedApplianceType = option
                self.removeSelectorController()
                
            }
            pickerController.onSelectionChangeBlock = {
                (index, option) -> () in
                sender.setTitle(option, forState: .Normal)
            }
            displaySelectorController(pickerController)
        }
    }
    
    @IBAction func showCoreSelector(sender: AnyObject!) {
        if let sb = self.storyboard {
            let pickerController = sb.instantiateViewControllerWithIdentifier(kPopupSelectorViewControllerIdentifier) as! PopupSelectorViewController
            pickerController.options = SharedSparkCoreManager.cores.map { $0.coreDescription }
            pickerController.titleText = "Select your core"
            pickerController.onDismissBlock = {
                (index, option) -> () in
                self.selectedCoreName = option
                self.removeSelectorController()
            }
            pickerController.onSelectionChangeBlock = {
                (index, option) -> () in
                sender.setTitle(option, forState: .Normal)
            }
            
            displaySelectorController(pickerController)
        }
    }
    
    func createAppliance(sender: AnyObject) {
        let label = applianceNameTextField.text
        let pin = 1 as UInt8
        let type = selectedApplianceType
        let core = SharedSparkCoreManager.getCore(selectedCoreName)
        if (SharedApplianceManager.createAppliance(label, core: core, pin: pin, type: type)) {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let alertController = UIAlertController(title: "Error", message: "There was a problem creating the appliance",
                preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default) {
                [unowned self](action) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
                })
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension AddApplianceTableViewController {
    func displaySelectorController(controller: PopupSelectorViewController) {
        selectorController = controller
        selectorController?.modalPresentationCapturesStatusBarAppearance = false
        selectorController?.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func removeSelectorController() {
        if let c = selectorController {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}