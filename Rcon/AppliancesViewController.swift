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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addAppliance(sender: AnyObject) {
        let label = applianceTypes[SharedApplianceManager.appliances.count]
        let pin = UInt8(SharedApplianceManager.appliances.count)
        
        let core = SharedSparkCoreManager.cores.first!
        
        SharedApplianceManager.createAppliance(label, core: core, pin: pin)
        appliancesCollectionView.reloadData()
    }
    
    @IBAction func unwindToAppliances(sender: UIStoryboardSegue) {
        NSLog("unwinded!")
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
            UIView.performWithoutAnimation {
                [unowned self] () -> () in
                self.appliancesCollectionView.reloadItemsAtIndexPaths([indexPath])
            }
        }
    }
    
    func scheduleButtonTapped(cell: ApplianceCell) {
        NSLog("go to schedule")
    }
}