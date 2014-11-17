//
//  AppDelegate.swift
//  LollyMac
//
//  Created by zhaowei on 2014/11/08.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var wc: SearchDictWindowController!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        wc = SearchDictWindowController(windowNibName: "SearchDictWindowController")
        wc.showWindow(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

