//
//  MainViewController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/18.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class MainViewController: AMSlideMenuMainViewController {
    
    override func segueIdentifierForIndexPathInLeftMenu(indexPath: NSIndexPath) -> String {
        return
            indexPath.row == 0 ? "searchSegue" :
            indexPath.row == 1 ? "langSegue" :
            "dictSegue"
    }
    
    override func leftMenuWidth() -> CGFloat {
        return 250
    }
    
    override func rightMenuWidth() -> CGFloat {
        return 180
    }
    
    override func configureLeftMenuButton(button: UIButton) {
        button.frame = CGRectMake(0, 0, 25, 13)
        button.backgroundColor = UIColor.clearColor()
        button.setImage(UIImage(named: "simpleMenuButton"), forState: UIControlState.Normal)
    }
    
    override func configureSlideLayer(layer: CALayer) {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSizeMake(0, 0)
        layer.shadowRadius = 5
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(rect: view.layer.bounds).CGPath
    }

    
    override func primaryMenu() -> AMPrimaryMenu {
        return AMPrimaryMenuLeft
    }
    
    
    // Enabling Deepnes on left menu
    override func deepnessForLeftMenu() -> Bool {
        return true
    }
    
    // Enabling darkness while left menu is opening
    override func maxDarknessWhileLeftMenu() -> CGFloat {
        return 0.5
    }

}
