//
//  AppliancesViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/26/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

class AppliancesViewController: UIViewController {
    
    @IBOutlet weak var appliancesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appliancesCollectionView.dataSource = self
        if let flowLayout = appliancesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let screenWidth = Double(UIScreen.mainScreen().bounds.width)
            let itemSideLength = (screenWidth * 0.96) / 2.0
            let itemSize = CGSize(width: itemSideLength, height: itemSideLength)
            let spacing = CGFloat((screenWidth - (2.0 * itemSideLength)) / 3.0)
            flowLayout.itemSize = itemSize
            flowLayout.minimumInteritemSpacing = spacing / 2.0
            flowLayout.minimumLineSpacing = spacing
            flowLayout.sectionInset = UIEdgeInsets(
                top: spacing,
                left: spacing,
                bottom: spacing,
                right: spacing
            )
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        /*
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("runAssistant") {
            if let storyboard = self.storyboard {
                if let vc = storyboard.instantiateViewControllerWithIdentifier("ConnectStripToNetworkScene") as? UIViewController {
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }
        }
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        appliancesCollectionView.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "applianceStateChangeNotificationReceived:",
            name: kApplianceStateChangedNotification,
            object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kApplianceStateChangedNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToAppliances(sender: UIStoryboardSegue) {
        NSLog("unwinded!")
    }
    
    func applianceStateChangeNotificationReceived(notification: NSNotification) {
        if let index = find(SharedApplianceManager.appliances, notification.object as! Appliance) {
            let ip = NSIndexPath(forItem: index, inSection: 0)
            dispatch_async(dispatch_get_main_queue()) {
                [unowned self] () -> () in
                self.appliancesCollectionView.reloadItemsAtIndexPaths([ip])
            }
        }
    }

}

extension AppliancesViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SharedApplianceManager.appliances.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ApplianceCell.ReuseIdentifier, forIndexPath: indexPath) as! ApplianceCell
        cell.delegate = self
        let appliance = SharedApplianceManager.appliances[indexPath.item]
        cell.setAppliance(appliance)
        return cell
    }
}

extension AppliancesViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

extension AppliancesViewController: ApplianceCellDelegate {
    func applianceButtonTapped(cell: ApplianceCell) {
        NSLog("toggle appliance state")
        if let indexPath = appliancesCollectionView.indexPathForCell(cell) {
            var appliance = SharedApplianceManager.appliances[indexPath.item]
            appliance.toggle()
            appliance.state = .UpdatingState
            UIView.performWithoutAnimation {
                [unowned self] () -> () in
                self.appliancesCollectionView.reloadItemsAtIndexPaths([indexPath])
            }
        }
    }
    
    func deleteButtonTapped(cell: ApplianceCell) {
        if let indexPath = appliancesCollectionView.indexPathForCell(cell) {
            var appliance = SharedApplianceManager.appliances[indexPath.item]
            
            let alertController = UIAlertController(title: "Are you sure?", message: "You will delete this appliance", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .Destructive) {
                [unowned self] (action) -> Void in
                SharedApplianceManager.deleteAppliance(appliance)
                self.appliancesCollectionView.deleteItemsAtIndexPaths([indexPath])
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel) {
                [unowned self] (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func scheduleButtonTapped(cell: ApplianceCell) {
        NSLog("go to schedule")
    }
}