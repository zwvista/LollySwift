//
//  WordsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/01/05.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class WordsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, WKNavigationDelegate, LollyProtocol {
    var selectedDictPickerIndex = 0
    
    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var tfNewWord: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    let disposeBag = DisposeBag()
    
    @objc var newWord = ""
    var selectedWord = ""
    var status = DictWebViewStatus.ready

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        guard searchfield === tfNewWord else {return}
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        addNewWord()
    }
    
    @IBAction func searchNewWord(_ sender: AnyObject) {
        commitEditing()
        guard !newWord.isEmpty else {return}
        searchWord(word: newWord)
    }
    
    func searchWord(word: String) {
        selectedWord = word
        let item = vmSettings.arrDictsPicker[selectedDictPickerIndex]
        if item.DICTNAME.starts(with: "Custom") {
            let str = vmSettings.dictHtml(word: word, dictids: item.dictids())
            wvDict.loadHTMLString(str, baseURL: nil)
        } else {
            let item2 = vmSettings.arrDictsWord.first { $0.DICTNAME == item.DICTNAME }!
            let url = item2.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
            if item2.DICTTYPENAME == "OFFLINE" {
                wvDict.load(URLRequest(url: URL(string: "about:blank")!))
                RestApi.getHtml(url: url).subscribe(onNext: { html in
                    print(html)
                    let str = item2.htmlString(html, word: self.newWord)
                    self.wvDict.loadHTMLString(str, baseURL: nil)
                }).disposed(by: disposeBag)
            } else {
                wvDict.load(URLRequest(url: URL(string: url)!))
                if item2.DICTTYPENAME == "OFFLINE-ONLINE" {
                    status = .navigating
                }
            }
        }
    }
    
    @IBAction func searchDict(_ sender: Any) {
        if sender is NSToolbarItem {
            let tbItem = sender as! NSToolbarItem
            selectedDictPickerIndex = tbItem.tag
            print(tbItem.toolbar!.selectedItemIdentifier!.rawValue)
        }
        if tableView.selectedRow == -1 {
            searchWord(word: newWord)
        } else {
            searchWordInTableView()
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        searchDict(self)
    }
    
    func googleWord(word: String) {
        NSWorkspace.shared.open([URL(string: "https://www.google.com/search?q=\(word)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!],
                                withAppBundleIdentifier:"com.apple.Safari",
                                options: [],
                                additionalEventParamDescriptor: nil,
                                launchIdentifiers: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.window?.makeKeyAndOrderFront(self)
        tableView.becomeFirstResponder()
        guard status == .navigating else {return}
        let item = vmSettings.arrDictsPicker[selectedDictPickerIndex]
        let item2 = vmSettings.arrDictsWord.first { $0.DICTNAME == item.DICTNAME }!
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
            print(html)
            let str = item2.htmlString(html, word: self.selectedWord)
            self.wvDict.loadHTMLString(str, baseURL: nil)
            self.status = .ready
        }
    }
    
    @IBAction func addNewWord(_ sender: Any) {
        addNewWord()
    }

    func addNewWord() {
    }
    
    func searchWordInTableView() {
    }

    func settingsChanged() {
        selectedDictPickerIndex = vmSettings.selectedDictPickerIndex
    }
}

class WordsWindowController: NSWindowController, NSToolbarDelegate, LollyProtocol {
    
    @IBOutlet weak var toolbar: NSToolbar!
    // Outlet collections have been implemented for iOS, but not in Cocoa
    // https://stackoverflow.com/questions/24805180/swift-put-multiple-iboutlets-in-an-array
    // @IBOutlet var tbiDicts: [NSToolbarItem]!
    @IBOutlet weak var tbiDict0: NSToolbarItem!
    @IBOutlet weak var tbiDict1: NSToolbarItem!
    @IBOutlet weak var tbiDict2: NSToolbarItem!
    @IBOutlet weak var tbiDict3: NSToolbarItem!
    @IBOutlet weak var tbiDict4: NSToolbarItem!
    @IBOutlet weak var tbiDict5: NSToolbarItem!
    @IBOutlet weak var tbiDict6: NSToolbarItem!
    @IBOutlet weak var tbiDict7: NSToolbarItem!
    @IBOutlet weak var tbiDict8: NSToolbarItem!
    @IBOutlet weak var tbiDict9: NSToolbarItem!
    @IBOutlet weak var tbiDict10: NSToolbarItem!
    @IBOutlet weak var tbiDict11: NSToolbarItem!
    @IBOutlet weak var tbiDict12: NSToolbarItem!
    @IBOutlet weak var tbiDict13: NSToolbarItem!
    @IBOutlet weak var tbiDict14: NSToolbarItem!
    @IBOutlet weak var tbiDict15: NSToolbarItem!
    @IBOutlet weak var tbiDict16: NSToolbarItem!
    @IBOutlet weak var tbiDict17: NSToolbarItem!
    @IBOutlet weak var tbiDict18: NSToolbarItem!
    @IBOutlet weak var tbiDict19: NSToolbarItem!
    @objc var vm: SettingsViewModel {return vmSettings}
    private var defaultToolbarItemCount = 0
    
    var identifiers: [NSToolbarItem.Identifier]!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.defaultToolbarItemCount = self.toolbar.items.count
            self.settingsChanged()
        }
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let dictName = itemIdentifier.rawValue
        let i = vmSettings.arrDictsPicker.firstIndex { $0.DICTNAME == dictName }!
        let item = self.value(forKey: "tbiDict\(i)") as! NSToolbarItem
        item.label = dictName
        item.target = contentViewController
        item.action = #selector(WordsViewController.searchDict(_:))
        if i == vmSettings.selectedDictPickerIndex {
            toolbar.selectedItemIdentifier = item.itemIdentifier
        }
        return item
    }
    
    func settingsChanged() {
        while toolbar.items.count > defaultToolbarItemCount {
            toolbar.removeItem(at: defaultToolbarItemCount)
        }
        for i in 0..<vmSettings.arrDictsPicker.count {
            let itemIdentifier = NSToolbarItem.Identifier(vmSettings.arrDictsPicker[i].DICTNAME)
            toolbar.insertItem(withItemIdentifier: itemIdentifier, at: defaultToolbarItemCount + i)
        }
    }
}
