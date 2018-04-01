//
//  AppDelegate.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    fileprivate let _theSettingsViewModel = SettingsViewModel()
    static var theSettingsViewModel: SettingsViewModel {
        return (NSApplication.shared.delegate as! AppDelegate)._theSettingsViewModel
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        _theSettingsViewModel.getData {}
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed() -> Bool {
        return true
    }
    
    @IBAction func settings(_ sender: AnyObject) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SettingsWindowController")) as! NSWindowController
        NSApplication.shared.runModal(for: wc.window!)
    }
    
    @IBAction func wordsInUnit(_ sender: AnyObject) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Words"), bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WordsUnitWindowController")) as! NSWindowController
        wc.showWindow(self)
    }
}
