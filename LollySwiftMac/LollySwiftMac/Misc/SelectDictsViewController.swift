//
//  SelectDictsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/04/05.
//  Copyright © 2020 趙偉. Available rights reserved.
//

import Cocoa
import Combine

class SelectDictsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tvAvailable: NSTableView!
    @IBOutlet weak var tvSelected: NSTableView!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnRemoveAll: NSButton!

    var vm: SettingsViewModel { AppDelegate.theSettingsViewModel }
    var dictsAvailable: [MDictionary]!
    var dictsSelected: [MDictionary]!
    var complete: (() -> Void)?
    var subscriptions = Set<AnyCancellable>()

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        tvSelected.registerForDraggedTypes([tableRowDragType])
        dictsSelected = vm.selectedDictsReference
        updateDictsAvailable()

        func updateDictsAvailable() {
            dictsAvailable = vm.arrDictsReference.filter { d in !dictsSelected.contains { $0.DICTNAME == d.DICTNAME } }
        }
        func updateDictsAvailableAndUI() {
            updateDictsAvailable()
            tvAvailable.reloadData()
            tvSelected.reloadData()
        }

        btnAdd.tapPublisher.sink { [unowned self] in
            for i in tvAvailable.selectedRowIndexes {
                dictsSelected.append(dictsAvailable[i])
            }
            updateDictsAvailableAndUI()
        } ~ subscriptions
        btnRemove.tapPublisher.sink { [unowned self] in
            for i in tvSelected.selectedRowIndexes.reversed() {
                dictsSelected.remove(at: i)
            }
            updateDictsAvailableAndUI()
        } ~ subscriptions
        btnRemoveAll.tapPublisher.sink { [unowned self] in
            dictsSelected.removeAll()
            updateDictsAvailableAndUI()
        } ~ subscriptions

        btnOK.tapPublisher.sink { [unowned self] in
            vm.selectedDictsReferenceIndexes = dictsSelected.compactMap { o in vm.arrDictsReference.firstIndex { $0.DICTID == o.DICTID } }
            Task {
                await vm.updateDictsReference()
                complete?()
                dismiss(btnOK)
            }
        } ~ subscriptions
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Select Dictionaries"
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvAvailable ? dictsAvailable.count : dictsSelected.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvAvailable {
            let item = dictsAvailable[row]
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
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { [unowned self] (draggingItem, _, _) in
            if let str = (draggingItem.item as! NSPasteboardItem).string(forType: tableRowDragType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }

        var oldIndexOffset = 0
        var newIndexOffset = 0

        func moveRow(at oldIndex: Int, to newIndex: Int) {
            dictsSelected.moveElement(at: oldIndex, to: newIndex)
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

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
