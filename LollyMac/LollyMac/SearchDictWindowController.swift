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
    @IBOutlet var dictAllController: NSArrayController!
    
    var word = ""
    var theLollyViewModel = LollyViewModel()
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        wvDictOffline.hidden = true
        langSelected(self)
    }
    
    @IBAction func searchDict(sender: AnyObject) {
        wvDictOnline.hidden = false
        wvDictOffline.hidden = true

        let m = theLollyViewModel.currentDict
        let url = m.urlString(word)
        wvDictOnline.mainFrameURL = url
    }

    @IBAction func langSelected(sender: AnyObject) {
        dictAllController.content = theLollyViewModel.arrDictAll
        dictSelected(sender)
    }
    
    @IBAction func dictSelected(sender: AnyObject) {
        if sender !== self {
            searchDict(sender)
        }
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        let searchfield = obj.object as! NSControl
        if searchfield !== sfWord {return}
        
        let dict = obj.userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.intValue)
        if code == NSReturnTextMovement {
            searchDict(self)
        }
    }
    
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        if frame !== sender.mainFrame {return}
        let m = theLollyViewModel.currentDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {return}
        
        let data = frame.dataSource!.data
        let html = NSString(data: data!, encoding: NSUTF8StringEncoding)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.mainFrame.loadHTMLString(str, baseURL: NSURL(string: "/Users/bestskip/Documents/zw/"))
        wvDictOnline.hidden = true
        wvDictOffline.hidden = false
    }
    
}
