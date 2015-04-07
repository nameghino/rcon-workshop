//
//  CoresViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/28/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

let kCoresViewControllerUnwindFromDoneIdentifier = "CoresViewControllerUnwindFromDone"
let kCoresViewControllerUnwindFromCancelIdentifier = "CoresViewControllerUnwindFromCancel"
let kShowCoreInformationDetailSegueIdentifier = "ShowCoreInformationDetailSegue"

class CoresViewController: UIViewController {
    
    @IBOutlet weak var coresTableView: UITableView!
    var updateTasks = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coresTableView.dataSource = self
        coresTableView.rowHeight = UITableViewAutomaticDimension
        coresTableView.estimatedRowHeight = CoreTableViewCell.EstimatedRowHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindToList(sender: UIStoryboardSegue) {
        coresTableView.reloadData()
        NSLog("unwinded!")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kShowCoreInformationDetailSegueIdentifier {
            let destination = segue.destinationViewController as! CoreInformationViewController
            let index = coresTableView.indexPathForCell(sender as! UITableViewCell)?.row
            let core = SharedSparkCoreManager.cores[index!]
            destination.core = core
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        updateTasks.each { SharedSparkService.cancelRequest($0) }
        updateTasks.removeAll(keepCapacity: false)
    }
    
}

extension CoresViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedSparkCoreManager.cores.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            CoreTableViewCell.ReuseIdentifier,
            forIndexPath: indexPath) as! CoreTableViewCell
        
        let core = SharedSparkCoreManager.cores[indexPath.row]
        cell.setCore(core)
        if core.needsStatusUpdate() {
            let taskId = core.updateCloudState() {
                [unowned self](_, _) -> () in
                dispatch_async(dispatch_get_main_queue()) {
                    self.coresTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
            updateTasks.append(taskId)
        }
        return cell
    }
}

extension CoresViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            SharedSparkCoreManager.deleteCore(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        default:
            break
        }
    }
}