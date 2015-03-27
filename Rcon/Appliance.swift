//
//  Appliance.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/27/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

enum ApplianceState {
    case PoweredOn
    case PoweredOff
    case UpdatingState
    case Scheduled
    case Unknown
}

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

/*
 * Appliance
 *
 * State: 
 *                      / Powered on  -> Updating
 * Unknown -> Updating -
 *                      \ Powered off -> Updating
 */

class Appliance {
    var label: String
    let core: SparkCore
    let pin: UInt8
    let schedule: [ApplianceSchedule]
    
    var state: ApplianceState = .Unknown
    var iconName: String
    
    init(label: String, core: SparkCore, pin: UInt8) {
        self.label = label
        self.core = core
        self.pin = pin
        self.schedule = []
        self.iconName = label
        
        switch rand() % 4 {
        case 0:
            state = .PoweredOn
        case 1:
            state = .PoweredOff
        case 2:
            state = .UpdatingState
        default:
            state = .Unknown
        }
        
    }
    
    func toggle() {}
    
    func powerOn() {
        core.setPin(Int(pin), level: LogicLevel.High)
    }
    
    func powerOff() {
        core.setPin(Int(pin), level: LogicLevel.Low)
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