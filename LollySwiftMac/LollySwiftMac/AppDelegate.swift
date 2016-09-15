//
//  AppDelegate.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import LollySwiftShared

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    fileprivate let _theSettingsViewModel = SettingsViewModel()
    static var theSettingsViewModel: SettingsViewModel {
        return (NSApplication.sharedApplication().delegate as! AppDelegate)._theSettingsViewModel
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed() -> Bool {
        return true
    }
    
    @IBAction func selectUnits(_ sender: AnyObject) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: "Select Units Window Controller") as! NSWindowController
        if let w = wc.window {
            //let vc = w.contentView as! SettingsViewController
            let application = NSApplication.shared()
            application.runModal(for: w)

        }
    }
    
    
}
