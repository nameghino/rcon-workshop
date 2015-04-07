//
//  Helper.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 4/7/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import Foundation
import UIKit

func GetDocumentsDirectory() -> String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
}