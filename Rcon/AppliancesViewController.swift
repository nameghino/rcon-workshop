//
//  AppliancesViewController.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/26/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

struct Core {
    let coreId: String
    let authToken: String
}

struct ApplianceSchedule {
    let from: NSDate
    let to: NSDate
    let pinState: UInt8
}

struct Appliance {
    let label: String
    let core: Core
    let pin: UInt8
    let schedule: [ApplianceSchedule]
    
    var isOn: Bool
    var iconName: String {
        get {
            let color = isOn ? "red" : "grey"
            return "\(label)-\(color)"
        }
    }
    
    init(label: String, core: Core, pin: UInt8) {
        self.label = label
        self.core = core
        self.pin = pin
        self.schedule = []
        self.isOn = false
    }
}

class ApplianceManager {
    var appliances: [Appliance]
    
    init() {
        appliances = []
    }
    
    func createAppliance(label: String, core: Core, pin: UInt8) {
        let a = Appliance(label: label, core: core, pin: pin)
        self.appliances.append(a)
    }
}

class ApplianceCell: UICollectionViewCell {
    static let ReuseIdentifier: String = "ApplianceCell"
    @IBOutlet weak var applianceButton: UIButton!
    @IBOutlet weak var scheduleButton: UIButton!
    
    func setAppliance(appliance: Appliance) {
        if let image = UIImage(named: appliance.iconName) {
            applianceButton.setImage(image, forState: .Normal)
        }
    }
}

let core = Core(coreId: "MY-SPARK-CORE", authToken: "MY-AUTH-TOKEN")
let ApplianceManagerInstance = ApplianceManager()
var applianceTypes = ["blender", "fan", "fridge", "heater-horizontal", "projector", "stove", "toaster", "washing-machine"]

class AppliancesViewController: UIViewController {
    
    @IBOutlet weak var appliancesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appliancesCollectionView.dataSource = self
        //appliancesCollectionView.registerClass(ApplianceCell.self, forCellWithReuseIdentifier: ApplianceCell.ReuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addAppliance(sender: AnyObject) {
        let label = applianceTypes.removeAtIndex(0)
        let pin = UInt8(ApplianceManagerInstance.appliances.count)
        ApplianceManagerInstance.createAppliance(label, core: core, pin: pin)
        appliancesCollectionView.reloadData()
    }
}

extension AppliancesViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ApplianceManagerInstance.appliances.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ApplianceCell", forIndexPath: indexPath) as! ApplianceCell
        
        let appliance = ApplianceManagerInstance.appliances[indexPath.item]
        cell.setAppliance(appliance)
        return cell
    }
}