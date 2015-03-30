//
//  SparkCore.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/27/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

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
}

class SparkCore: NSObject {
    var coreId: String
    var authToken: String
    var state: SparkCoreStatus
    var isOnline: Bool { get { return state == .Online } }
    var coreDescription: String
    var lastHeard: NSDate
    var pinState: [LogicLevel] = []
    
    init(description: String, coreId: String, authToken: String) {
        self.coreId = coreId
        self.authToken = authToken
        self.state = .Unknown
        self.coreDescription = description
        self.lastHeard = NSDate.distantPast() as! NSDate
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


    func updateCloudState(callback: SparkCoreCommandCallback) {
        let request = SharedSparkService.submit(SparkServiceEndpoints.CoreInformation(self)) {
            [unowned self](error, info) -> Void in
            if let name = info["name"] as? String {
                self.coreDescription = name
            }
            if let connected = info["connected"] as? Bool {
                if connected {
                    self.state = .Online
                } else {
                    self.state = .Offline
                }
            }
            if let cb = callback {
                cb(error, info)
            }
        }
        
    }
}

class SparkCoreManager {
    var cores: [SparkCore] = []
    func addCore(description: String, coreId: String, authToken: String) {
        cores.append(SparkCore(description: description, coreId: coreId, authToken: authToken))
    }
}

