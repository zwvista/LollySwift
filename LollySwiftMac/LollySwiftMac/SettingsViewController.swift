//
//  SettingsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/23.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        langSelected(self)
    }
    @IBAction func close(_ sender: AnyObject) {
        let application = NSApplication.shared()
        application.stopModal()
        // http://stackoverflow.com/questions/5711367/os-x-how-can-a-nsviewcontroller-find-its-window
        self.view.window?.close()
    }
    
    @IBAction func langSelected(_ sender: AnyObject) {
        dictSelected(sender)
    }
    
    @IBAction func dictSelected(_ sender: AnyObject) {
    }
    
    
    @IBAction func textbookSelected(_ sender: AnyObject) {
    }
    
    
    
    
}
