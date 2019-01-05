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

class WordsUnitViewController: WordsViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var tfNewWord: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    var timer = Timer()
    @objc var newWord = ""
    var selectedWord = ""
    var status = DictWebViewStatus.ready

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] {
        return vm.arrWords
    }
    
    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerForDraggedTypes([tableRowDragType])
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
        cell.textField?.stringValue = columnName == "PART" ? item.PARTSTR(arrParts: vm.vmSettings.arrParts) : String(describing: item.value(forKey: columnName) ?? "")
        return cell;
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: tableRowDragType)
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { (draggingItem, _, _) in
            if let str = (draggingItem.item as! NSPasteboardItem).string(forType: self.tableRowDragType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }
        
        var oldIndexOffset = 0
        var newIndexOffset = 0
        
        func moveRow(at oldIndex: Int, to newIndex: Int) {
            vm.moveWord(at: oldIndex, to: newIndex)
            tableView.moveRow(at: oldIndex, to: newIndex)
        }
        
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                oldIndexOffset -= 1
            } else {
                moveRow(at: oldIndex, to: row + newIndexOffset)
                newIndexOffset += 1
            }
        }
        let col = tableView.tableColumns.index(where: {$0.title == "SEQNUM"})!
        vm.reindex {
            tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
        }
        tableView.endUpdates()
        
        return true
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
        WordsUnitViewModel.update(item: item).subscribe().disposed(by: disposeBag)
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
        let mWord = vm.newUnitWord()
        mWord.WORD = newWord
        WordsUnitViewModel.create(item: mWord).subscribe(onNext: {
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
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        detailVC.vm = vm
        detailVC.mWord = vm.newUnitWord()
        detailVC.complete = { self.tableView.reloadData(); self.addWord(self) }
        self.presentAsSheet(detailVC)
    }
    
    @IBAction func deleteWord(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editWord(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.mWord = vm.arrWords[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func getNote(_ sender: Any) {
        let col = tableView.tableColumns.index(where: {$0.title == "NOTE"})!
        vm.getNote(index: tableView.selectedRow).subscribe {
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }
    
    @IBAction func copyWord(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        MacApi.copyText(item.WORD)
    }
    
    @IBAction func googleWord(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        NSWorkspace.shared.open([URL(string: "https://www.google.com/search?q=\(item.WORD)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!],
                                withAppBundleIdentifier:"com.apple.Safari",
                                options: [],
                                additionalEventParamDescriptor: nil,
                                launchIdentifiers: nil)
    }
    
    @IBAction func getNotes(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "Retrieve Notes"
        alert.informativeText = "question"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Empty Notes Only")
        alert.addButton(withTitle: "All Notes")
        alert.addButton(withTitle: "Cancel")
        let res = alert.runModal()
        if res != .alertThirdButtonReturn {
            var subscription: Disposable?
            vm.getNotes(ifEmpty: res == .alertFirstButtonReturn) {
                let scheduler = SerialDispatchQueueScheduler(qos: .default)
                subscription = Observable<Int>.interval(Double($0) / 1000.0, scheduler: scheduler)
                    .subscribe { _ in
                        self.vm.getNextNote(rowComplete: {
                            self.tableView.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
                        }, allComplete: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                subscription?.dispose()
                                // self.tableView.reloadData()
                            }
                        })
                    }
            }
        }
    }
    
    override func settingsChanged() {
        super.settingsChanged()
        refreshTableView(self)
    }

    deinit {
    }
}

class WordsUnitWindowController: WordsWindowController {
    override func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = super.toolbar(toolbar, itemForItemIdentifier: itemIdentifier, willBeInsertedIntoToolbar: flag)!
        item.action = #selector(WordsUnitViewController.searchWordInTableView(_:))
        return item
    }
}

