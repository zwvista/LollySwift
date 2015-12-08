//
//  LollyUINavigationController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/18.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

public extension UINavigationController {
    override func shouldAutorotate() -> Bool {
        return true
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
    }
}

var stack: NSMutableArray?

class LollyUINavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if stack?.count > 0 {
            //restoring navigation state if exists
            viewControllers = stack!.mutableCopy() as! [UIViewController];
            stack = nil
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Saving navigation state
        stack = NSMutableArray(array: viewControllers)
    }
    
    override class func initialize() {
        super.initialize()
        
        /*
        * We need to set a memory warning listener,
        * to deallocate recreatable resources
        */
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleDidReceiveMemoryWarning",
            name: UIApplicationDidReceiveMemoryWarningNotification,
            object: UIApplication.sharedApplication());
    }
    
    /*
    * Cleaning up some memory
    */
    class func handleDidReceiveMemoryWarning(note: NSNotification) {
        stack = nil;
    }
}
