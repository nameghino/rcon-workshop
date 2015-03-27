//
//  ApplianceCell.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/27/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

protocol ApplianceCellDelegate: class {
    func applianceButtonTapped(cell: ApplianceCell)
    func scheduleButtonTapped(cell: ApplianceCell)
}

class ApplianceCell: UICollectionViewCell {
    static let ReuseIdentifier: String = "ApplianceCell"
    
    weak var delegate: ApplianceCellDelegate?
    
    @IBOutlet weak var applianceButton: UIButton!
    @IBOutlet weak var scheduleButton: UIButton!
    
    override func awakeFromNib() {
        setup()
    }
    
    func setup() {
        contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "applianceButtonTapped:"))
        applianceButton.addTarget(self, action: "applianceButtonTapped:", forControlEvents: .TouchUpInside)
        //scheduleButton.addTarget(self, action: "scheduleButtonTapped:", forControlEvents: .TouchUpInside)
    }
    
    override func layoutSubviews() {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
    func setAppliance(appliance: Appliance) {
        
        let color: UIColor
        
        let animationAdded = applianceButton.imageView?.layer.animationForKey("iconPulseAnimation") != nil
        
        if appliance.state == .UpdatingState && !animationAdded {
            addPulseAnimation()
        } else if appliance.state != .UpdatingState && animationAdded {
            removePulseAnimation()
        }
        
        switch appliance.state {
        case .PoweredOff:
            color = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        case .PoweredOn:
            color = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        case .Scheduled:
            color = UIColor(red: 0.1, green: 0.1, blue: 0.8, alpha: 1.0)
        case .UpdatingState:
            color = UIColor(red: 0.8, green: 0.8, blue: 0.1, alpha: 1.0)
        case .Unknown:
            color = UIColor(white: 0.5, alpha: 1.0)
        }
        
        applianceButton.tintColor = color
        
        if let image = UIImage(named: appliance.iconName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate) {
            applianceButton.setImage(image, forState: .Normal)
        } else {
            NSLog("icon for \(appliance.iconName) not found")
        }
    }
    
    func addPulseAnimation() {
        let pulseAnimation = CAKeyframeAnimation(keyPath: "opacity")
        pulseAnimation.duration = 2.0
        pulseAnimation.values = [1.0, 0.0, 1.0]
        pulseAnimation.keyTimes = [0, 0.5, 1]
        pulseAnimation.repeatCount = Float.infinity
        applianceButton.imageView?.layer.addAnimation(pulseAnimation, forKey: "iconPulseAnimation")
    }
    
    func removePulseAnimation() {
        applianceButton.imageView?.layer.removeAnimationForKey("iconPulseAnimation")
    }
    
    override func prepareForReuse() {
        applianceButton.setImage(nil, forState: .Normal)
        removePulseAnimation()
    }
    
    func applianceButtonTapped(button: UIButton!) {
        self.delegate?.applianceButtonTapped(self)
    }
    
    func scheduleButtonTapped(button: UIButton!) {
        self.delegate?.scheduleButtonTapped(self)
    }
}