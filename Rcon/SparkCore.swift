//
//  SparkCore.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/27/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit
import Foundation

typealias JSONDictionary = [String:AnyObject]
typealias SparkCoreCommandCallback = ((NSError!, JSONDictionary) -> Void)?

let SharedSparkCoreManager = SparkCoreManager()

enum SparkPin: String {
    case Analog = "A"
    case Digital = "D"
    case Relay = "R"
}

enum LogicLevel: Int {
    case Low = 0
    case High = 1
}

enum SparkCoreStatus {
    case Unknown
    case Online
    case Offline
    case Error
}

class SparkCore: NSObject, NSCoding {
    var coreId: String
    var authToken: String
    var state: SparkCoreStatus {
        didSet {
            if state == .Online {
                lastHeard = NSDate()
            }
        }
    }
    var isOnline: Bool { get { return state == .Online } }
    var coreDescription: String
    var lastHeard: NSDate
    var pinState: [LogicLevel] = []
    var message: String?
    var appliances: [Appliance] = []
    var lastCloudStatusUpdate: NSDate
    
    init(description: String, coreId: String, authToken: String) {
        self.coreId = coreId
        self.authToken = authToken
        self.state = .Unknown
        self.coreDescription = description
        self.lastHeard = NSDate.distantPast() as! NSDate
        self.lastCloudStatusUpdate = NSDate.distantPast() as! NSDate
    }
    
    required init(coder aDecoder: NSCoder) {
        self.coreId = aDecoder.decodeObjectForKey("coreId") as! String
        self.coreDescription = aDecoder.decodeObjectForKey("coreDescription") as! String
        self.lastHeard = aDecoder.decodeObjectForKey("lastHeard") as! NSDate
        self.authToken = aDecoder.decodeObjectForKey("authToken") as! String
        self.state = .Unknown
        self.appliances = aDecoder.decodeObjectForKey("appliances") as! [Appliance]
        self.lastCloudStatusUpdate = aDecoder.decodeObjectForKey("lastCloudStatusUpdate") as! NSDate
        super.init()
        for appliance in self.appliances {
            appliance.core = self
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.coreId, forKey: "coreId")
        aCoder.encodeObject(self.coreDescription, forKey: "coreDescription")
        aCoder.encodeObject(self.lastHeard, forKey: "lastHeard")
        aCoder.encodeObject(self.authToken, forKey: "authToken")
        aCoder.encodeObject(self.appliances, forKey: "appliances")
        aCoder.encodeObject(self.lastCloudStatusUpdate, forKey: "lastCloudStatusUpdate")
    }
    
    
    func setPin(pin: Int, level: LogicLevel) {
        let taskId = SharedSparkService.submit(.SetPin(self, pin, level)) {
            (error, response) -> Void in
            NSLog("setPin(\(pin), \(level.rawValue)) -> (\(error.localizedDescription), \(response))")
        }
    }
    
    /*
    * Response
    
    {
    "id": "53ff75065075535155461187",
    "name": "HOME",
    "connected": true,
    "variables": {
    "pinState": "string"
    },
    "functions": [
    "setPin",
    "timedPin",
    "togglePin"
    ],
    "cc3000_patch_version": "1.29",
    "last_heard": "2015-03-28T15:38:01.142Z"
    }
    */
    
    
    func needsStatusUpdate() -> Bool {
        let interval = fabs(lastCloudStatusUpdate.timeIntervalSinceNow)
        return interval > 60
    }
    
    
    func updateCloudState(callback: SparkCoreCommandCallback) -> String {
        let taskId = SharedSparkService.submit(SparkServiceEndpoints.CoreInformation(self)) {
            [unowned self](error, info) -> Void in
            if let errorTitle = info["error"] as? String {
                self.state = .Error
                self.message = "\(errorTitle)"
            } else {
                
                if let name = info["name"] as? String {
                    self.coreDescription = name
                }
                if let connected = info["connected"] as? Bool {
                    if connected {
                        self.state = .Online
                        self.lastHeard = NSDate()
                    } else {
                        self.state = .Offline
                    }
                    self.lastCloudStatusUpdate = NSDate()
                } else {
                    self.state = .Unknown
                }
            }
            if let cb = callback {
                cb(error, info)
            }
        }
        return taskId
    }
    
    func updatePinState(callback: SparkCoreCommandCallback) -> String {
        let taskId = SharedSparkService.submit(SparkServiceEndpoints.PinState(self)) {
            [unowned self](error, info) -> Void in
        }
        return taskId
    }
}

class SparkCoreManager {
    
    var cores: [SparkCore] = []
    
    static let filename = "cores.archive"
    static var filepath: String {
        get {
            return GetDocumentsDirectory().stringByAppendingPathComponent(filename)
        }
    }
    
    init() {
        load()
    }
    
    func addCore(description: String, coreId: String, authToken: String) {
        cores.append(SparkCore(description: description, coreId: coreId, authToken: authToken))
        if !save() {
            NSLog("error saving core table: \(strerror(errno))")
        }
    }
    
    func deleteCore(core: SparkCore) {
        if let index = find(cores, core) {
            cores.removeAtIndex(index)
            if !save() {
                NSLog("error saving core table: \(strerror(errno))")
            }
        }
    }
    
    func deleteCore(index: Int) {
        cores.removeAtIndex(index)
        if !save() {
            NSLog("error saving core table: \(strerror(errno))")
        }
    }
    
    func save() -> Bool {
        return NSKeyedArchiver.archiveRootObject(cores, toFile: SparkCoreManager.filepath)
    }
    
    func load() {
        NSLog("\(SparkCoreManager.filepath)")

        if let savedCores = NSKeyedUnarchiver.unarchiveObjectWithFile(SparkCoreManager.filepath) as? [SparkCore] {
            cores = savedCores
        }
    }
}

