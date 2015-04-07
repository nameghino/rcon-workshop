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



enum SparkServiceErrors: Int {
    case NonstandardError = -1
    case OK = 200
    case BadRequest = 400
    case Unauthorized = 401
    case Forbidden = 403
    case NotFound = 404
    case TimedOut = 408
    case InternalServerError = 500

    static var Domain = "SparkCloudAPIDomain"
    
    var description: String {
        get {
            switch self {
            case .OK:
                return "All good"
            case .BadRequest:
                return "Your request is not understood by the Core, or the requested subresource (variable/function) has not been exposed."
            case .Unauthorized:
                return "Your access token is not valid"
            case .Forbidden:
                return "Your access token is not authorized to interface with this Core."
            case .NotFound:
                return "The Core you requested is not currently connected to the cloud."
            case .TimedOut:
                return "The cloud experienced a significant delay when trying to reach the Core."
            case .InternalServerError:
                return "Spark Cloud is not working correctly. Your core can't be reached until Spark fixes their cloud."
            default:
                return "Check the returned JSON for more information"
            }
        }
    }
}

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
            if dict != nil {
                return NSJSONSerialization.dataWithJSONObject(dict!, options: .allZeros, error: nil)
            } else {
                return nil
            }
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
                    NSLog("data task error: \(error.localizedDescription)")
                    cb(error, [:])
                } else {
                    if let httpResponse = response as? NSHTTPURLResponse {
                        var jsonError: NSError?
                        if let jdict = NSJSONSerialization.JSONObjectWithData(data,
                            options: NSJSONReadingOptions.allZeros,
                            error: &jsonError) as? JSONDictionary {
                                if httpResponse.statusCode > 399 {
                                    NSLog("server side error")
                                    // server side error
                                    let apiError: NSError
                                    if let standardError = SparkServiceErrors(rawValue: httpResponse.statusCode) {
                                        // known errors
                                        NSLog("standard server side error")
                                        apiError = NSError(domain: SparkServiceErrors.Domain,
                                            code: standardError.rawValue,
                                            userInfo: [NSLocalizedDescriptionKey: standardError.description])
                                        
                                    } else {
                                        // unknown errors
                                        NSLog("nonstandard server side error")
                                        apiError = NSError(domain: SparkServiceErrors.Domain,
                                            code: SparkServiceErrors.NonstandardError.rawValue,
                                            userInfo: [NSLocalizedDescriptionKey: SparkServiceErrors.NonstandardError.description])
                                    }
                                    cb(apiError, jdict)
                                } else {
                                    NSLog("all good!")
                                    cb(nil, jdict)
                                }
                        } else {
                            NSLog("error parsing json")
                            cb(jsonError!, [:])
                        }
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
