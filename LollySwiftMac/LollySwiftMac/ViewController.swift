//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit

@objcMembers
class ViewController: NSViewController, NSSearchFieldDelegate {
    
    @IBOutlet weak var wvDictOnline: WKWebView!
    @IBOutlet weak var sfWord: NSSearchField!
    @IBOutlet weak var wvDictOffline: WKWebView!
    
    var word = ""
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wvDictOffline.isHidden = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func searchDict(_ sender: AnyObject) {
        wvDictOnline.isHidden = false
        wvDictOffline.isHidden = true
        
        let m = vm.selectedDict
        let url = m.urlString(word)
        wvDictOnline.load(URLRequest(url: URL(string: url)!))
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        if searchfield !== sfWord {return}
        
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        if code == NSReturnTextMovement {
            searchDict(self)
        }
    }
    
    func webView(_ sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        if frame !== sender.mainFrame {return}
        let m = vm.selectedDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {return}
        
        let data = frame.dataSource!.data
        let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.loadHTMLString(str, baseURL: URL(string: "/Users/bestskip/Documents/zw/"))
        wvDictOnline.isHidden = true
        wvDictOffline.isHidden = false
    }


}

