//
//  SparkCore.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/27/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

class SparkCore: NSObject {
    let coreId: String
    let authToken: String
    
    init(coreId: String, authToken: String) {
        self.coreId = coreId
        self.authToken = authToken
    }
}
