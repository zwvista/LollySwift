//
//  TransformEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/28.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import WebKit

class TransformEditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var complete: (() -> Void)?
    @objc var vm = TransformEditViewModel()

    @IBOutlet weak var tvTranformItems: NSTableView!
    @IBOutlet weak var tfSourceWord: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tvSource: NSTextView!
    @IBOutlet weak var wvSource: WKWebView!
    @IBOutlet weak var tvResult: NSTextView!
    @IBOutlet weak var wvResult: WKWebView!
    @IBOutlet weak var tvInterim: NSTextView!
    @IBOutlet weak var tvTemplate: NSTextView!
    
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.initItems()
        tvTranformItems.reloadData()
        tvTranformItems.registerForDraggedTypes([tableRowDragType])
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        vm.arrTranformItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        let item = vm.arrTranformItems[row]
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
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
            vm.moveTransformItem(at: oldIndex, to: newIndex)
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
        let col = tableView.tableColumns.firstIndex { $0.identifier.rawValue == "index" }!
        vm.reindex {
            tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
        }
        tableView.endUpdates()
        
        return true
    }
    
    @IBAction func addTransformItem(_ sender: AnyObject) {
        let itemEditVC = self.storyboard!.instantiateController(withIdentifier: "TransformItemEditController") as! TransformItemEditController
        itemEditVC.item = vm.newTransformItem()
        itemEditVC.complete = { self.tvTranformItems.reloadData() }
        self.presentAsSheet(itemEditVC)
    }

    @IBAction func editTransformItem(_ sender: AnyObject) {
        let itemEditVC = self.storyboard!.instantiateController(withIdentifier: "TransformItemEditController") as! TransformItemEditController
        let i = tvTranformItems.selectedRow
        itemEditVC.item = MTransformItem()
        itemEditVC.item.copy(from: vm.arrTranformItems[i])
        itemEditVC.complete = {
            self.vm.arrTranformItems[i].copy(from: itemEditVC.item)
            self.tvTranformItems.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvTranformItems.tableColumns.count))
        }
        self.presentAsModalWindow(itemEditVC)
    }

    @IBAction func getHtml(_ sender: Any) {
        vm.getHtml()
        wvSource.load(URLRequest(url: URL(string: vm.sourceUrl)!))
    }
    
    @IBAction func executeTransform(_ sender: Any) {
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
