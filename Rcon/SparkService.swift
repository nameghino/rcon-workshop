//
//  SparkService.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/27/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

extension NSData {
    var stringRepresentation: String {
        get {
            return NSString(data: self, encoding: NSUTF8StringEncoding) as! String
        }
    }
}

let SharedSparkService = SparkService()
let kAPIHost = "https://api.spark.io"
let kAPIVersion = "v1"

enum SparkServiceEndpoints {
    case CoreInformation(SparkCore)
    case SetPin(SparkCore, Int, LogicLevel)
    case TimedPin(SparkCore, Int, Int)
    case TogglePin(SparkCore, Int)
    case PinState(SparkCore)
    
    var core: SparkCore {
        get {
            switch self {
            case let .SetPin(core, _, _):
                return core
            case let .TimedPin(core, _, _):
                return core
            case let .TogglePin(core, _):
                return core
            case let .PinState(core):
                return core
            case let .CoreInformation(core):
                return core
            }
        }
    }
    
    var URL: NSURL {
        get {
            let endpoint: String
            switch self {
            case .CoreInformation(let core):
                endpoint = "devices/\(core.coreId)"
            case .SetPin(let core, _, _):
                endpoint = "/devices/\(core.coreId)/setPin"
            case .TimedPin(let core, _, _):
                endpoint = "/devices/\(core.coreId)/timedPin"
            case .TogglePin(let core, _):
                endpoint = "/devices/\(core.coreId)/togglePin"
            case .PinState(let core):
                endpoint = "/devices/\(core.coreId)/pinState"
            }
            let URLString = kAPIHost.stringByAppendingPathComponent(kAPIVersion).stringByAppendingPathComponent(endpoint)
            return NSURL(string: URLString)!
        }
    }
    
    var method: String {
        get {
            switch self {
            case .PinState(_):
                fallthrough
            case .CoreInformation(_):
                return "GET"
            case .SetPin(_, _, _):
                fallthrough
            case .TimedPin(_, _, _):
                fallthrough
            case .TogglePin(_, _):
                return "POST"
            }
        }
    }
    
    var data: NSData? {
        get {
            let dict: JSONDictionary?
            switch self {
            case let .SetPin(_, pin, level):
                dict = ["args": "D\(pin)@\(level.rawValue)"]
            case let .TimedPin(_, pin, millis):
                dict = ["args": "D\(pin)@\(millis)"]
            case let .TogglePin(_, pin):
                dict = ["args": "D\(pin)@1"]
            default:
                dict = nil
            }
            return NSJSONSerialization.dataWithJSONObject(dict!, options: .allZeros, error: nil)
        }
    }
    
    private func createBaseRequest(core: SparkCore) -> NSMutableURLRequest {
        let r = NSMutableURLRequest(URL: self.URL)
        r.setValue("Bearer \(core.authToken)", forHTTPHeaderField: "Authorization")
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r.setValue("application/json", forHTTPHeaderField: "Accept")
        return r
    }
    
    var request: NSMutableURLRequest {
        get {
            let r = createBaseRequest(self.core)
            r.HTTPMethod = self.method
            if let d = self.data {
                r.HTTPBody = d
            }
            return r
        }
    }
}

class SparkService: NSObject {
    
    var activeTasks: [String : NSURLSessionTask]
    
    override init() {
        activeTasks = [:]
    }
    
    func submit(endpoint: SparkServiceEndpoints, callback: SparkCoreCommandCallback) -> String {
        return self.submitRequest(endpoint.request, callback: callback)
    }
    
    private func submitRequest(request: NSURLRequest, callback: SparkCoreCommandCallback) -> String {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in
            if let cb = callback {
                if error != nil {
                    NSLog("error: \(error.localizedDescription)")
                    cb(error, [:])
                } else {
                    NSLog("response: \(data.stringRepresentation)")
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
        let taskIdentifier = NSUUID().UUIDString
        activeTasks[taskIdentifier] = task
        NSLog("requesting \(request.URL?.absoluteString)")
        task.resume()
        return taskIdentifier
    }
    
    func cancelRequest(taskIdentifier: String) {
        if let task = activeTasks[taskIdentifier] {
            task.cancel()
        }
    }
    
    func cancelAllRequests() {
        for (_, task) in activeTasks {
            task.cancel()
        }
    }
}
