//
//  AppDelegate.swift
//  LollyMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed() -> Bool {
        return true
    }
    
    @IBAction func selectUnits(sender: AnyObject) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let wc = storyboard.instantiateControllerWithIdentifier("Select Units Window Controller") as! NSWindowController
        if let w = wc.window {
            //let vc = w.contentView as! SelectUnitsViewController
            let application = NSApplication.sharedApplication()
            application.runModalForWindow(w)

        }
    }
    
    
}
