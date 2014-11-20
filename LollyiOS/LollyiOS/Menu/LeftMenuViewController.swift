//
//  LeftMenuViewController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/18.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class LeftMenuViewController: AMSlideMenuLeftTableViewController {
    var myTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 7.0 && !UIApplication.sharedApplication().statusBarHidden {
            tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            // The device is an iPhone or iPod touch.
            setFixedStatusBar();
        }
    }
    
    func setFixedStatusBar() {
        myTableView = tableView;
        
        view = UIView(frame: view.bounds)
        view.backgroundColor = myTableView.backgroundColor
        view.addSubview(myTableView)
        
        let statusBarView = UIView(frame: CGRectMake(0, 0, max(view.frame.size.width, view.frame.size.height), 20));
        statusBarView.backgroundColor = UIColor.clearColor();
        view.addSubview(statusBarView);
    }

}
