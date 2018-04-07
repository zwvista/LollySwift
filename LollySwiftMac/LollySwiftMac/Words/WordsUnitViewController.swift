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
    
    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wvDictOffline.isHidden = true
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
        let m = arrWords[row]
        let columnName = tableColumn!.title
        cell.textField?.stringValue = columnName == "PART" ? m.PARTSTR(arrParts: vm.vmSettings.arrParts) : String(describing: m.value(forKey: columnName)!)
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
        let m = arrWords[row]
        let oldValue = String(describing: m.value(forKey: key)!)
        let newValue = sender.stringValue
        guard oldValue != newValue else {return}
        m.setValue(newValue, forKey: key)
        WordsUnitViewModel.update(m.ID, m: MUnitWordEdit(m: m)) {}
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let m = arrWords[tableView.selectedRow]
        word = m.WORD
        searchDict(self)
    }
    
    @IBAction func searchDict(_ sender: AnyObject) {
        wvDictOnline.isHidden = false
        wvDictOffline.isHidden = true
        
        let m = vm.vmSettings.selectedDict
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
        let m = vm.vmSettings.selectedDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {return}
        
        let data = frame.dataSource!.data
        let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.loadHTMLString(str, baseURL: URL(string: "/Users/bestskip/Documents/zw/"))
        wvDictOnline.isHidden = true
        wvDictOffline.isHidden = false
    }

    lazy var detailVC = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WordsUnitDetailViewController")) as! WordsUnitDetailViewController

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: Any) {
        detailVC.vm = vm
        detailVC.mWord = vm.newUnitWord()
        self.presentViewControllerAsSheet(detailVC)
    }
    
    @IBAction func deleteWord(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel) {
            self.tableView.reloadData()
        }
    }

    @IBAction func tableViewDoubleAction(_ sender: Any) {
        detailVC.vm = vm
        detailVC.mWord = vm.arrWords[tableView.selectedRow]
        self.presentViewControllerAsModalWindow(detailVC)
    }
}

