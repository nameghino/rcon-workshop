//
//  AppDelegate.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/26/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func application(application: UIApplication,
        handleWatchKitExtensionRequest
        userInfo: [NSObject : AnyObject]?,
        reply: (([NSObject : AnyObject]!) -> Void)!) {
    }
}

