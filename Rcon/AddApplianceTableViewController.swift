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
    
    var dimmerLayer: CALayer! = nil
    var selectorController: PopupSelectorViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                NSLog("core selected: \(option)")
                self.removeSelectorController()
            }
            pickerController.onSelectionChangeBlock = {
                (index, option) -> () in
                sender.setTitle(option, forState: .Normal)
            }
            
            displaySelectorController(pickerController)
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