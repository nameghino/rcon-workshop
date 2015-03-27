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

enum SparkPin: String {
    case Analog = "A"
    case Digital = "D"
    case Relay = "R"
}

enum LogicLevel: Int {
    case Low = 0
    case High = 1
}

enum SparkCommand {
    static let endpoint = NSURL(string: "https://api.spark.io")!
    
    case SetPin(SparkPin, Int, Int)
    case TimedPin(SparkPin, Int, Int)
    
    var functionName: String {
        get {
            switch self {
            case .SetPin(_, _, _):
                return "setPin"
            case .TimedPin(_, _, _):
                return "timedPin"
            }
        }
    }
    
    var stringValue: String {
        get {
            switch self {
            case .SetPin(let type, let pin, let level):
                return "\(type.rawValue)\(pin)@\(level)"
            case .TimedPin(let type, let pin, let millis):
                return "\(type.rawValue)\(pin)@\(millis)"
            }
        }
    }
    
    func request(token: String, coreId: String) -> NSURLRequest {
        let url = NSURL(string: "/v1/devices/\(coreId)/\(self.functionName)", relativeToURL: SparkCommand.endpoint)
        let r = NSMutableURLRequest(URL: url!)
        r.HTTPMethod = "POST"
        
        let data = NSJSONSerialization.dataWithJSONObject(["args": self.stringValue], options: NSJSONWritingOptions.allZeros, error: nil)
        
        r.HTTPBody = data
        r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return r
    }
}


class SparkCore: NSObject {
    var coreId: String
    var authToken: String
    var isOnline: Bool
    
    init(coreId: String, authToken: String) {
        self.coreId = coreId
        self.authToken = authToken
        self.isOnline = false
    }
    
    private func sendCommand(command: SparkCommand, callback: SparkCoreCommandCallback) {
        let session = NSURLSession.sharedSession()
        let request = command.request(self.authToken, coreId: self.coreId)
        NSLog("will hit: \(request.URL?.absoluteString)")
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in
            if let cb = callback {
                if error != nil {
                    cb(error, [:])
                } else {
                    var jsonError: NSError?
                    if let jdict = NSJSONSerialization.JSONObjectWithData(data,
                        options: NSJSONReadingOptions.allZeros,
                        error: &jsonError) as? JSONDictionary {
                            cb(nil, jdict)
                    } else {
                        cb(jsonError!, [:])
                    }
                    
                }
            }
        }
        task.resume()
    }
}

