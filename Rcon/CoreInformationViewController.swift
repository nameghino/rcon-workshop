//
//  CoreInformationViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 4/7/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

enum CoreInformationViewControllerSection: Int {
    case CoreInfo = 0
    case Appliances = 1
}

class CoreInformationViewController: UIViewController {

    var core: SparkCore!
    @IBOutlet weak var tableView: UITableView!
    lazy var NoAppliancesFooter: UILabel = {
        let label = UILabel()
        label.text = "No appliances"
        label.textAlignment = .Center
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    static let CellReuseIdentifier = "CoreInfomationCell"
    static let InformationFields = [
        ("coreDescription", "Description"),
        ("coreId", "Core ID"),
        ("authToken", "Token"),
        ("lastHeard", "Last Online"),
        ("message", "Status Message")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CoreInformationViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case CoreInformationViewControllerSection.CoreInfo.rawValue:
            return 5
        case CoreInformationViewControllerSection.Appliances.rawValue:
            return max(0, core.appliances.count)
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CoreInformationViewController.CellReuseIdentifier,
            forIndexPath: indexPath) as! UITableViewCell
        cell.selectionStyle = .None
        switch indexPath.section {
        case CoreInformationViewControllerSection.CoreInfo.rawValue:
            self.configureInfoCell(cell, forIndexPath: indexPath)
        case CoreInformationViewControllerSection.Appliances.rawValue:
            self.configureApplianceCell(cell, forIndexPath: indexPath)
        default:
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case CoreInformationViewControllerSection.CoreInfo.rawValue:
            return "Core Information"
        case CoreInformationViewControllerSection.Appliances.rawValue:
            return "Appliances at this core"
        default:
            return ""
        }
    }
    
    func configureInfoCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        let (key, title) = CoreInformationViewController.InformationFields[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = title
        if let value = core.valueForKey(key) {
            cell.detailTextLabel?.text = "\(value)"
        } else {
            cell.detailTextLabel?.text = "no value"
        }
    }
    
    func configureApplianceCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        let appliance = core.appliances[indexPath.row]
        cell.textLabel?.text = appliance.label
        cell.detailTextLabel?.text = appliance.state.description
    }
}


extension CoreInformationViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == CoreInformationViewControllerSection.Appliances.rawValue && core.appliances.count == 0 {
            return self.NoAppliancesFooter
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == CoreInformationViewControllerSection.Appliances.rawValue && core.appliances.count == 0 {
            return 60.0
        }
        return 0.0
    }
}