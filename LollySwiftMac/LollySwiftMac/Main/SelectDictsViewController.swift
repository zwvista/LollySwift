//
//  SelectDictsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/04/05.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class SelectDictsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tvAll: NSTableView!
    @IBOutlet weak var tvSelected: NSTableView!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnRemoveAll: NSButton!
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }
    let disposeBag = DisposeBag()
    var dictsAll: [MDictionary]!
    var dictsSelected: [MDictItem]!
    var complete: (() -> Void)?

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        tvSelected.registerForDraggedTypes([tableRowDragType])
        dictsSelected = vm.selectedDictItems
        updateDictsAll()
    }
    
    private func updateDictsAll() {
        dictsAll = vm.arrDictsReference.filter { d in !dictsSelected.contains { $0.DICTNAME == d.DICTNAME } }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableView === tvAll ? dictsAll.count : dictsSelected.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvAll {
            let item = dictsAll[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = dictsSelected[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
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
            let item = dictsSelected.remove(at: oldIndex)
            dictsSelected.insert(item, at: newIndex)
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
        tableView.endUpdates()

        return true
    }
    
    @IBAction func addRemoveItems(_ sender: AnyObject) {
        if sender === btnAdd {
            for i in tvAll.selectedRowIndexes {
                let o = dictsAll[i]
                dictsSelected.append(MDictItem(id: String(o.DICTID), name: o.DICTNAME))
            }
        } else if sender === btnRemove {
            for i in tvSelected.selectedRowIndexes.reversed() {
                dictsSelected.remove(at: i)
            }
        } else {
            dictsSelected.removeAll()
        }
        updateDictsAll()
        tvAll.reloadData()
        tvSelected.reloadData()
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        vm.selectedDictItems = dictsSelected
        vm.updateDictItems().subscribe {
            self.complete?()
        }.disposed(by: disposeBag)
        dismiss(self)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
