//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class SearchViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var sfWord: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!

    @objc
    var newWord = ""
    var status = DictWebViewStatus.ready
    
    var arrWords = [MUnitWord]()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let item = vmSettings.selectedDictOnline
        let url = item.urlString(word: newWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
        if item.DICTTYPENAME == "OFFLINE" {
            RestApi.getHtml(url: url).subscribe(onNext: { html in
                print(html)
                let str = item.htmlString(html, word: self.newWord)
                self.wvDict.loadHTMLString(str, baseURL: nil)
            }).disposed(by: disposeBag)
        } else {
            wvDict.load(URLRequest(url: URL(string: url)!))
            if item.DICTTYPENAME == "OFFLINE-ONLINE" {
                status = .navigating
            }
        }
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
        guard status == .navigating else {return}
        let item = vmSettings.selectedDictOnline
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
//            print(html)
            let str = item.htmlString(html, word: self.newWord)
            self.wvDict.loadHTMLString(str, baseURL: nil)
            self.status = .ready
        }
    }
    
    @IBAction func addWord(_ sender: Any) {
    }
    
    func settingsChanged() {
    }
}

class SearchWindowController: NSWindowController, LollyProtocol {
    
    @IBOutlet weak var acDictsOnline: NSArrayController!
    @IBOutlet weak var pubDictsOnline: NSPopUpButton!
    
    var vc: SearchViewController {return contentViewController as! SearchViewController}
    @objc var vm: SettingsViewModel {return vmSettings}
    
    override func windowDidLoad() {
        super.windowDidLoad()
        settingsChanged()
    }
    
    func settingsChanged() {
        acDictsOnline.content = vmSettings.arrDictsOnline
    }
    
    @IBAction func dictsOnlineChanged(_ sender: Any) {
        vc.searchDict(self)
    }
}


