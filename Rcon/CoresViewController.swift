//
//  CoresViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/28/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

class CoresViewController: UIViewController {

    @IBOutlet weak var coresTableView: UITableView!
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        return cell
        
    }
}