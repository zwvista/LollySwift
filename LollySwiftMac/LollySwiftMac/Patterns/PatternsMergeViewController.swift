//
//  PatternsMergeViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/10/30.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxBinding

class PatternsMergeViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tvPatterns: NSTableView!
    @IBOutlet weak var tvPatternVariations: NSTableView!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfTags: NSTextField!

    var vm: PatternsMergeViewModel!
    var itemEdit: MPatternEdit { vm.itemEdit }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        tvPatternVariations.registerForDraggedTypes([tableRowDragType])
        _ = itemEdit.PATTERN ~> tfPattern.rx.text.orEmpty
        _ = itemEdit.NOTE ~> tfNote.rx.text.orEmpty
        _ = itemEdit.TAGS ~> tfTags.rx.text.orEmpty
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPatterns ? vm.arrPatterns.count : vm.arrPatternVariations.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvPatterns {
            let item = vm.arrPatterns[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else if tableView === tvPatternVariations {
            let item = vm.arrPatternVariations[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tvPatternVariations.row(for: sender)
        guard row != -1 else {return}
        vm.arrPatternVariations[row].variation = sender.stringValue
        vm.mergeVariations()
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
            vm.arrPatternVariations.moveElement(at: oldIndex, to: newIndex)
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
        vm.reindexVariations {
            tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
        }
        tableView.endUpdates()

        vm.mergeVariations()

        return true
    }

    @IBAction func deleteVariation(_ sender: Any) {
        let row = tvPatternVariations.selectedRow
        guard row != -1 else {return}
        vm.arrPatternVariations.remove(at: row)
        tvPatternVariations.reloadData()
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        vm.onOK().subscribe { [unowned self] _ in
            dismiss(sender)
        } ~ rx.disposeBag
    }
}
