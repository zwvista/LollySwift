//
//  MainViewController.swift
//  LollySwiftiOS
//
//  Created by zhaowei on 2014/11/18.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class MainViewController: AMSlideMenuMainViewController {
    
    override func segueIdentifierForIndexPath(inLeftMenu indexPath: IndexPath) -> String {
        let arrSegues = [
            "searchSegue",
            "settingsSegue",
            "wordsUnitsSegue",
            "wordsTBSegue",
            "wordsLangSegue",
            "phrasesUnitsSegue",
            "phrasesLangSegue",
        ]
        return arrSegues[indexPath.row]
    }
    
    override func leftMenuWidth() -> CGFloat {
        return 250
    }
    
    override func rightMenuWidth() -> CGFloat {
        return 180
    }
    
    override func configureLeftMenuButton(_ button: UIButton) {
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 13)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "simpleMenuButton"), for: UIControlState())
    }
    
    override func configureSlideLayer(_ layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 5
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(rect: view.layer.bounds).cgPath
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
