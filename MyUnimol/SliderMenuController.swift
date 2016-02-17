//
//  SliderMenuController.swift
//  MyUnimol
//
//  Created by Giovanni Grano on 17/02/16.
//  Copyright © 2016 Giovanni Grano. All rights reserved.
//

import UIKit
import KYDrawerController

class SliderMenuController: UITableViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let closeButton    = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.addTarget(self,
            action: "didTapCloseButton:",
            forControlEvents: .TouchUpInside
        )
        closeButton.sizeToFit()
        closeButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        view.addSubview(closeButton)
        view.addConstraint(
            NSLayoutConstraint(
                item: closeButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: view,
                attribute: .CenterX,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: closeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: view,
                attribute: .CenterY,
                multiplier: 1,
                constant: 0
            )
        )
        view.backgroundColor = UIColor.whiteColor()
    }
    
    func didTapCloseButton(sender: UIButton) {
        if let drawerController = parentViewController as? KYDrawerController {
            drawerController.setDrawerState(.Closed, animated: true)
        }
    }
    
}