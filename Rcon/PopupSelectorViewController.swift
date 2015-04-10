//
//  PopupSelectorViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 4/10/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

typealias PopupSelectorViewControllerOnDismissBlock = ((Int, String) -> Void)!
typealias PopupSelectorViewControllerOnSelectionChangeBlock = ((Int, String) -> Void)!

class PopupSelectorViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pickerView: UIPickerView!
    var titleText: String = ""
    var onDismissBlock: PopupSelectorViewControllerOnDismissBlock = nil
    var onSelectionChangeBlock: PopupSelectorViewControllerOnSelectionChangeBlock = nil
    var options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        titleLabel.text = titleText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender: AnyObject!) {
        if onDismissBlock != nil {
            let index = pickerView.selectedRowInComponent(0)
            let option = options[index]
            onDismissBlock(index, option)
        }
    }
}


extension PopupSelectorViewController: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
}

extension PopupSelectorViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return options[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if onSelectionChangeBlock != nil {
            let index = pickerView.selectedRowInComponent(0)
            let option = options[index]
            onSelectionChangeBlock(index, option)
        }
    }
}