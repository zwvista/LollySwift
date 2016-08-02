//
//  SelectUnitsViewController.swift
//  LollyMac
//
//  Created by 趙偉 on 2016/07/23.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa

class SelectUnitsViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func close(sender: AnyObject) {
        let application = NSApplication.sharedApplication()
        application.stopModal()
        // http://stackoverflow.com/questions/5711367/os-x-how-can-a-nsviewcontroller-find-its-window
        self.view.window?.close()
    }
    
}
