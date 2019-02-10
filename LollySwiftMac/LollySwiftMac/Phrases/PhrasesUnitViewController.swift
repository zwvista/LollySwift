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

class PhrasesUnitViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var timer = Timer()
    @objc
    var newPhrase = ""
    
    var vm: PhrasesUnitViewModel!
    var arrPhrases: [MUnitPhrase] {
        return vm.arrPhrases
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
        return arrPhrases.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrPhrases[row]
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
            vm.movePhrase(at: oldIndex, to: newIndex)
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
        let item = arrPhrases[row]
        let oldValue = String(describing: item.value(forKey: key)!)
        let newValue = sender.stringValue
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        PhrasesUnitViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.window?.makeKeyAndOrderFront(self)
        tableView.becomeFirstResponder()
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
        detailVC.vm = vm
        detailVC.mPhrase = vm.newUnitPhrase()
        detailVC.complete = { self.tableView.reloadData(); self.addPhrase(self) }
        self.presentAsSheet(detailVC)
    }
    
    @IBAction func deletePhrase(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = PhrasesUnitViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editPhrase(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.mPhrase = vm.arrPhrases[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func copyPhrase(_ sender: Any) {
        let item = vm.arrPhrases[tableView.selectedRow]
        MacApi.copyText(item.PHRASE)
    }
    
    @IBAction func googlePhrase(_ sender: Any) {
        let item = vm.arrPhrases[tableView.selectedRow]
        MacApi.googleString(item.PHRASE)
    }
    
    func settingsChanged() {
        refreshTableView(self)
    }
}

class PhrasesUnitWindowController: NSWindowController, LollyProtocol {
    
    var vc: PhrasesUnitViewController {return contentViewController as! PhrasesUnitViewController}
    @objc var vm: SettingsViewModel {return vmSettings}
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func settingsChanged() {
        
    }
}

