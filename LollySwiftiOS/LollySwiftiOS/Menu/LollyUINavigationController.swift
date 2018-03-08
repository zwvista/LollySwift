//
//  LollyUINavigationController.swift
//  LollySwiftiOS
//
//  Created by zhaowei on 2014/11/18.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension UINavigationController {
    override open var shouldAutorotate : Bool {
        return true
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
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
    
    override func viewWillDisappear(_ animated: Bool) {
        // Saving navigation state
        stack = NSMutableArray(array: viewControllers)
    }
    
//    func initialize() {
//        super.initialize()
//
//        /*
//        * We need to set a memory warning listener,
//        * to deallocate recreatable resources
//        */
//        NotificationCenter.default.addObserver(self,
//            selector: #selector(LollyUINavigationController.handleDidReceiveMemoryWarning),
//            name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
//            object: UIApplication.shared);
//    }
    
    /*
    * Cleaning up some memory
    */
    @objc class func handleDidReceiveMemoryWarning(_ note: Notification) {
        stack = nil;
    }
}
