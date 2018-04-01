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
class WordsUnitViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSSearchFieldDelegate {
    
    @IBOutlet weak var wvDictOnline: WKWebView!
    @IBOutlet weak var sfWord: NSSearchField!
    @IBOutlet weak var wvDictOffline: WKWebView!
    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet weak var tfWord: NSTextField!
    var word = ""
    
    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] {
        return vm.arrWords
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wvDictOffline.isHidden = true
        
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel) {
            self.tableView.reloadData()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrWords.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        cell.textField?.stringValue = String(describing: arrWords[row].value(forKey: tableColumn!.title)!)
        return cell;
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let column = tableView.column(for: sender)
        let key = tableView.tableColumns[column].title
        let m = arrWords[row]
        let oldValue = String(describing: m.value(forKey: key)!)
        let newValue = sender.stringValue
        guard oldValue != newValue else {return}
        m.setValue(newValue, forKey: key)
        WordsUnitViewModel.update(m.ID, m: MUnitWordEdit(m: m)) {}
    }
    
    // https://developer.apple.com/videos/play/wwdc2011/120/
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let m = arrWords[tableView.selectedRow]
        word = m.WORD
        searchDict(self)
    }
    
    @IBAction func searchDict(_ sender: AnyObject) {
        wvDictOnline.isHidden = false
        wvDictOffline.isHidden = true
        
        let m = vm.settings.selectedDict
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
        let m = vm.settings.selectedDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {return}
        
        let data = frame.dataSource!.data
        let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.loadHTMLString(str, baseURL: URL(string: "/Users/bestskip/Documents/zw/"))
        wvDictOnline.isHidden = true
        wvDictOffline.isHidden = false
    }


}

