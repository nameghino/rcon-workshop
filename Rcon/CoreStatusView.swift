//
//  CoreStatusView.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/28/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

@IBDesignable
class CoreStatusView: UIView {
    @IBInspectable var color: UIColor!
    
    override func prepareForInterfaceBuilder() {
        backgroundColor = UIColor.clearColor()
    }
    
    override func awakeFromNib() {
        color = UIColor.purpleColor()
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, backgroundColor?.CGColor)
        CGContextFillRect(ctx, rect)
        let iconRect = CGRectInset(rect, 4, 4)
        let path = UIBezierPath(roundedRect: iconRect, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSizeMake(4, 4))
        color.setFill()
        path.fill()
    }
}
