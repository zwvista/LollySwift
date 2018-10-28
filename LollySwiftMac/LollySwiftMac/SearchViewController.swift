//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit

class SearchViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var wvDictOnline: WKWebView!
    @IBOutlet weak var sfWord: NSSearchField!
    @IBOutlet weak var wvDictOffline: WKWebView!
    @IBOutlet weak var tableView: NSTableView!

    @objc
    var newWord = ""
    
    var arrWords = [MUnitWord]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wvDictOffline.isHidden = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrWords.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return arrWords[row]
    }
    
    @IBAction func searchDict(_ sender: AnyObject) {
        wvDictOnline.isHidden = false
        wvDictOffline.isHidden = true
        
        let item = vmSettings.selectedDictOnline
        let url = item.urlString(word: newWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
        wvDictOnline.load(URLRequest(url: URL(string: url)!))
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        if searchfield !== sfWord {return}
        
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        if code == NSReturnTextMovement {
            searchDict(self)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView === wvDictOnline else {return}
        let item = vmSettings.selectedDictOnline
        guard item.DICTTYPENAME == "OFFLINE-ONLINE" else {return}
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
//            print(html)
            let str = item.htmlString(html, word: self.newWord)
            self.wvDictOffline.loadHTMLString(str, baseURL: nil)
            self.wvDictOnline.isHidden = true
            self.wvDictOffline.isHidden = false
        }
    }
    
    func settingsChanged() {
    }
}

