//
//  SparkService.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/27/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

let SharedSparkService = SparkService()
let kAPIHost = "https://api.spark.io"
let kAPIVersion = "v1"

enum SparkServiceEndpoints {
    case CoreInformation(SparkCore)
    
    var URL: NSURL {
        get {
            let endpoint: String
            switch self {
            case .CoreInformation(let core):
                endpoint = "devices/\(core.coreId)"
            }
            let URLString = kAPIHost.stringByAppendingPathComponent(kAPIVersion).stringByAppendingPathComponent(endpoint)
            return NSURL(string: URLString)!
        }
    }
}

class SparkService: NSObject {
    
    var activeTasks: [String : NSURLSessionTask]
    
    override init() {
        activeTasks = [:]
    }
    
    private func createSparkAPIRequest(core: SparkCore, targetURL: NSURL) -> NSMutableURLRequest {
        let r = NSMutableURLRequest(URL: targetURL)
        r.setValue("Bearer \(core.authToken)", forHTTPHeaderField: "Authorization")
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r.setValue("application/json", forHTTPHeaderField: "Accept")
        return r
    }
    
    func createSparkCoreInformationRequest(core: SparkCore) -> NSMutableURLRequest {
        return createSparkAPIRequest(core, targetURL: SparkServiceEndpoints.CoreInformation(core).URL)
    }
    
    func submitRequest(request: NSURLRequest, callback: SparkCoreCommandCallback) -> String {
        let session = NSURLSession.sharedSession()
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
