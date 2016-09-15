//
//  SettingsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/23.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import LollySwiftShared

class SettingsViewController: NSViewController {
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }
    @IBOutlet weak var dictionariesController: NSArrayController!
    @IBOutlet weak var textbooksController: NSArrayController!

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
        dictionariesController.content = vm.arrDictionaries
        textbooksController.content = vm.arrTextbooks
        dictSelected(sender)
    }
    
    @IBAction func dictSelected(_ sender: AnyObject) {
    }
    
    
    @IBAction func textbookSelected(_ sender: AnyObject) {
    }
    
    
    
    
}
