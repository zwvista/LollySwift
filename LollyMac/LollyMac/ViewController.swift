//
//  ViewController.swift
//  LollyMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import LollyShared

class ViewController: NSViewController, NSSearchFieldDelegate {
    
    @IBOutlet weak var wvDictOnline: WebView!
    @IBOutlet weak var sfWord: NSSearchField!
    @IBOutlet weak var wvDictOffline: WebView!
    @IBOutlet weak var dictionaryController: NSArrayController!
    
    var word = ""
    var theSettingsViewModel = SettingsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wvDictOffline.hidden = true
        langSelected(self)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func searchDict(sender: AnyObject) {
        wvDictOnline.hidden = false
        wvDictOffline.hidden = true
        
        let m = theSettingsViewModel.currentDict
        let url = m.urlString(word)
        wvDictOnline.mainFrameURL = url
    }
    
    @IBAction func langSelected(sender: AnyObject) {
        dictionaryController.content = theSettingsViewModel.arrDictionary
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
        let m = theSettingsViewModel.currentDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {return}
        
        let data = frame.dataSource!.data
        let html = NSString(data: data!, encoding: NSUTF8StringEncoding)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.mainFrame.loadHTMLString(str, baseURL: NSURL(string: "/Users/bestskip/Documents/zw/"))
        wvDictOnline.hidden = true
        wvDictOffline.hidden = false
    }


}

