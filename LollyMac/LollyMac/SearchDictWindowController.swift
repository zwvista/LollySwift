//
//  SearchDictWindowController.swift
//  LollyMac
//
//  Created by zhaowei on 2014/11/11.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Cocoa
import WebKit
import LollyShared

class SearchDictWindowController: NSWindowController, NSTextFieldDelegate {
    
    @IBOutlet var wvDictOnline: WebView!
    @IBOutlet var sfWord: NSSearchField!
    @IBOutlet var wvDictOffline: WebView!
    
    var word = ""
    var theLollyObject: LollyObject
    
    override init(window: NSWindow?) {
        theLollyObject = LollyObject()
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        wvDictOffline.hidden = true
        langSelected(self)
    }
    
    @IBAction func searchDict(sender: AnyObject) {
        wvDictOnline.hidden = false
        wvDictOffline.hidden = true
    }

    @IBAction func langSelected(sender: AnyObject) {
        
    }
    
    @IBAction func dictSelected(sender: AnyObject) {
        
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        
    }
    
    override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        if frame != sender.mainFrame {
            return
        }
        let m = theLollyObject.currentDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {
            return
        }
        
        let data = frame.dataSource?.data
        let html = NSString(data: data!, encoding: NSUTF8StringEncoding)
    }
    
}
