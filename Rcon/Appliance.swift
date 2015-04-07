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
    
    var description: String {
        get {
            switch self {
            case .PoweredOff:
                return "Appliance is off"
            case .PoweredOn:
                return "Appliance is on"
            case .UpdatingState:
                return "Updating state..."
            case .Scheduled:
                return "Appliance has a schedule"
            case .Unknown:
                return "Appliance state unknown"
            }
        }
    }
}

class ApplianceSchedule: NSObject, NSCoding {
    let from: NSDate
    let to: NSDate
    let pinState: UInt8
    
    override init() {
        from = NSDate()
        to = from
        pinState = 0
    }
    
    required init(coder aDecoder: NSCoder) {
        from = aDecoder.decodeObjectForKey("fromDate") as! NSDate
        to = aDecoder.decodeObjectForKey("toDate") as! NSDate
        pinState = (aDecoder.decodeObjectForKey("pinState") as! NSNumber).unsignedCharValue
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(from, forKey: "fromDate")
        aCoder.encodeObject(to, forKey: "toDate")
        aCoder.encodeObject(NSNumber(unsignedChar: pinState), forKey: "pinState")
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

class Appliance: NSObject, NSCoding {
    var label: String
    weak var core: SparkCore?
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
        
        let s = Int(arc4random_uniform(4))
        
        switch s % 4 {
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
    
    required init(coder aDecoder: NSCoder) {
        self.label = aDecoder.decodeObjectForKey("label") as! String
        self.pin = (aDecoder.decodeObjectForKey("pin") as! NSNumber).unsignedCharValue
        self.schedule = aDecoder.decodeObjectForKey("schedule") as! [ApplianceSchedule]
        self.iconName = aDecoder.decodeObjectForKey("iconName") as! String
        self.state = .Unknown
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(label, forKey: "label")
        aCoder.encodeObject(NSNumber(unsignedChar: pin), forKey: "pin")
        aCoder.encodeObject(schedule, forKey: "schedule")
        aCoder.encodeObject(iconName, forKey: "iconName")
    }
    
    func toggle() {
        switch self.state {
        case .PoweredOff:
            self.state = .PoweredOn
        case .PoweredOn:
            self.state = .PoweredOff
        default:
            break
        }
    }
    
    func powerOn() {
        core!.setPin(Int(pin), level: LogicLevel.High)
    }
    
    func powerOff() {
        core!.setPin(Int(pin), level: LogicLevel.Low)
    }
}

class ApplianceManager {
    var appliances: [Appliance] {
        get {
            return SharedSparkCoreManager.cores.flatMap() { return $0.appliances }
        }
    }
    
    func createAppliance(label: String, core: SparkCore, pin: UInt8) -> Bool {
        let a = Appliance(label: label, core: core, pin: pin)
        core.appliances.append(a)
        return SharedSparkCoreManager.save()
    }
    
    func deleteAppliance(appliance: Appliance) -> Bool {
        if let index = find(appliance.core!.appliances, appliance) {
            appliance.core?.appliances.removeAtIndex(index)
            return SharedSparkCoreManager.save()
        }
        return false
    }
}

let SharedApplianceManager = ApplianceManager()