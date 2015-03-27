//
//  Appliance.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/27/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

class ApplianceSchedule {
    let from: NSDate
    let to: NSDate
    let pinState: UInt8
    
    init() {
        from = NSDate()
        to = from
        pinState = 0
    }
}

class Appliance {
    let label: String
    let core: SparkCore
    let pin: UInt8
    let schedule: [ApplianceSchedule]
    
    var isOn: Bool
    var iconName: String {
        get {
            let color = isOn ? "on" : "off"
            //return "\(label)-\(color)"
            return "\(label)-off"
        }
    }
    
    init(label: String, core: SparkCore, pin: UInt8) {
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
    
    func createAppliance(label: String, core: SparkCore, pin: UInt8) {
        let a = Appliance(label: label, core: core, pin: pin)
        self.appliances.append(a)
    }
}

let SharedApplianceManager = ApplianceManager()