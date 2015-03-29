//
//  CoreTableViewCell.swift
//  Rcon
//
//  Created by Nicolas Ameghino on 3/28/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit

class CoreTableViewCell: UITableViewCell {
    
    static var ReuseIdentifier: String { get { return "CoreTableViewCell" } }
    static var EstimatedRowHeight: CGFloat { get { return 60.0 } }
    
    @IBOutlet weak var coreDescriptionLabel: UILabel!
    @IBOutlet weak var coreIdLabel: UILabel!
    @IBOutlet weak var coreStatusView: CoreStatusView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coreStatusView.backgroundColor = UIColor.clearColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setStatusColor(core: SparkCore) {
        let statusColor: UIColor
        switch (core.state) {
        case .Online:
            statusColor = UIColor.greenColor()
        case .Offline:
            statusColor = UIColor.redColor()
        case .Unknown:
            statusColor = UIColor.grayColor()
        }
        coreStatusView.color = statusColor
        coreStatusView.setNeedsDisplay()
    }
    
    func setCore(core: SparkCore) {
        coreIdLabel.text = core.coreId
        coreDescriptionLabel.text = core.coreDescription
        setStatusColor(core)
        core.updateCloudState() {
            [unowned self] (error, dictionary) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.setStatusColor(core)
            }
        }
    }
    
}
