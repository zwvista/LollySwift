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

class WordsLangViewController: WordsViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var tfNewWord: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    var timer = Timer()
    @objc var newWord = ""
    var selectedWord = ""
    var status = DictWebViewStatus.ready

    var vm: WordsLangViewModel!
    var arrWords: [MLangWord] {
        return vm.arrWords
    }
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTableView(self)
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
        let item = arrWords[row]
        let columnName = tableColumn!.title
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell;
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].title
        let item = arrWords[row]
        let oldValue = String(describing: item.value(forKey: key))
        let newValue = sender.stringValue
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        WordsLangViewModel.update(item: item).subscribe().disposed(by: disposeBag)
    }
    
    func searchWord(word: String) {
        selectedWord = word
        let item = vmSettings.arrDictsOnline[selectedDictOnlineIndex]
        let url = item.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        if item.DICTTYPENAME == "OFFLINE" {
            wvDict.load(URLRequest(url: URL(string: "about:blank")!))
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
    
    @IBAction func searchWordInTableView(_ sender: Any) {
        if sender is NSToolbarItem {
            let tbItem = sender as! NSToolbarItem
            selectedDictOnlineIndex = tbItem.tag
            print(tbItem.toolbar!.selectedItemIdentifier!.rawValue)
        }
        guard tableView.selectedRow != -1 else {return}
        searchWord(word: arrWords[tableView.selectedRow].WORD)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        searchWordInTableView(self)
    }
    
    @IBAction func addNewWord(_ sender: AnyObject) {
        guard !newWord.isEmpty else {return}
        let mWord = vm.newLangWord()
        mWord.WORD = newWord
        WordsLangViewModel.create(item: mWord).subscribe(onNext: {
            mWord.ID = $0
            self.vm.arrWords.append(mWord)
            self.tableView.reloadData()
            self.tfNewWord.stringValue = ""
            self.newWord = ""
        }).disposed(by: disposeBag)
    }
    
    @IBAction func searchNewWord(_ sender: AnyObject) {
        commitEditing()
        guard !newWord.isEmpty else {return}
        searchWord(word: newWord)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        guard searchfield === tfNewWord else {return}
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        addNewWord(self)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.window?.makeKeyAndOrderFront(self)
        tableView.becomeFirstResponder()
        guard status == .navigating else {return}
        let item = vmSettings.selectedDictOnline
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
            print(html)
            let str = item.htmlString(html, word: self.selectedWord)
            self.wvDict.loadHTMLString(str, baseURL: nil)
            self.status = .ready
        }
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vm = vm
        detailVC.mWord = vm.newLangWord()
        detailVC.complete = { self.tableView.reloadData(); self.addWord(self) }
        self.presentAsSheet(detailVC)
    }
    
    @IBAction func deleteWord(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = WordsLangViewModel(settings: AppDelegate.theSettingsViewModel) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editWord(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.mWord = vm.arrWords[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func copyWord(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(item.WORD, forType: .string)
    }
    
    @IBAction func googleWord(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        NSWorkspace.shared.open([URL(string: "https://www.google.com/search?q=\(item.WORD)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!],
                                withAppBundleIdentifier:"com.apple.Safari",
                                options: [],
                                additionalEventParamDescriptor: nil,
                                launchIdentifiers: nil)
    }
    
    override func settingsChanged() {
        super.settingsChanged()
        refreshTableView(self)
    }

    deinit {
    }
}

class WordsLangWindowController: WordsWindowController {
    override var toolbarItemCount: Int { return 3 }
    override func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = super.toolbar(toolbar, itemForItemIdentifier: itemIdentifier, willBeInsertedIntoToolbar: flag)!
        item.action = #selector(WordsLangViewController.searchWordInTableView(_:))
        return item
    }
}

