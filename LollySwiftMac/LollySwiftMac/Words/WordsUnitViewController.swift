//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import Combine

class WordsUnitViewController: WordsBaseViewController, NSMenuItemValidation, NSToolbarItemValidation {

    var vm: WordsUnitViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrWords: [MUnitWord] { vm.arrWordsFiltered }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        tvWords.registerForDraggedTypes([tableRowDragType])
        vm.$arrWordsFiltered.didSet.sink { [unowned self] _ in
            self.doRefresh()
        } ~ subscriptions
    }

    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(getNote(_:)) || menuItem.action == #selector(getNotes(_:)) {
            return vmSettings.hasDictNote
        }
        return true
    }

    // https://stackoverflow.com/questions/8017822/how-to-enable-disable-nstoolbaritem
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        let s = item.paletteLabel
        let enabled = !((s == "Previous" || s == "Next" || s == "U <-> P") && vmSettings.toType == .to || s == "Notes" && !vmSettings.hasDictNote)
        return enabled
    }

    override func settingsChanged() {
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: true, needCopy: true) {}
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvWords ? arrWords.count : vmPhrasesLang.arrPhrases.count
    }

    override func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }

    override func endEditing(row: Int) {
        let item = arrWords[row]
        Task {
            await vm.update(item: item)
            tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if vmSettings.isSingleUnitPart && vm.arrWordsFiltered == nil {
            let item = NSPasteboardItem()
            item.setString(String(row), forType: tableRowDragType)
            return item
        } else {
            return nil
        }
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
            vm.arrWords.moveElement(at: oldIndex, to: newIndex)
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
        let col = tableView.tableColumns.firstIndex { $0.identifier.rawValue == "SEQNUM" }!
        Task {
            await vm.reindex {
                tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
            }
            tableView.endUpdates()
        }

        return true
    }

    override func addNewWord() {
        guard !vm.newWord.isEmpty else {return}
        let item = vm.newUnitWord()
        item.WORD = vmSettings.autoCorrectInput(text: vm.newWord)
        tfNewWord.stringValue = ""
        vm.newWord = ""
        Task {
            await vm.create(item: item)
            tvWords.reloadData()
            tvWords.selectRowIndexes(IndexSet(integer: arrWords.count - 1), byExtendingSelection: false)
            responder = tfNewWord
        }
    }

    func addWord(phraseid: Int) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        detailVC.startEdit(vm: vm, item: vm.newUnitWord(), phraseid: phraseid)
        detailVC.complete = { self.tvWords.reloadData(); self.addWord(self) }
        self.presentAsSheet(detailVC)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: AnyObject) {
        addWord(phraseid: 0)
    }

    override func deleteWord(row: Int) {
        let item = arrWords[row]
        Task {
            await WordsUnitViewModel.delete(item: item)
            doRefresh()
        }
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        Task {
            await vm.reload()
        }
    }

    @IBAction func doubleAction(_ sender: AnyObject) {
        if NSApp.currentEvent!.modifierFlags.contains(.option) {
            associateExistingPhrases(sender)
        } else {
            editWord(sender)
        }
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        let i = tvWords.selectedRow
        if i == -1 {return}
        detailVC.startEdit(vm: vm, item: arrWords[tvWords.selectedRow], phraseid: 0)
        detailVC.complete = {
            self.tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }

    @IBAction func batchAdd(_ sender: AnyObject) {
        let batchVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitBatchAddViewController") as! WordsUnitBatchAddViewController
        batchVC.startEdit(vm: vm)
        batchVC.complete = { self.doRefresh() }
        self.presentAsModalWindow(batchVC)
    }

    @IBAction func batchEdit(_ sender: AnyObject) {
        let batchVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitBatchEditViewController") as! WordsUnitBatchEditViewController
        let i = tvWords.selectedRow
        let item = i == -1 ? nil : arrWords[i]
        batchVC.startEdit(vm: vm, unit: item?.UNIT ?? vmSettings.USUNITTO, part: item?.PART ?? vmSettings.USPARTTO)
        batchVC.complete = { self.doRefresh() }
        self.presentAsModalWindow(batchVC)
    }

    @IBAction func getNote(_ sender: AnyObject) {
        Task {
            let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
            await vm.getNote(index: tvWords.selectedRow)
            tvWords.reloadData(forRowIndexes: [tvWords.selectedRow], columnIndexes: [col])
        }
    }

    @IBAction func getNotes(_ sender: AnyObject) {
        Task {
            let ifEmpty = sender is NSToolbarItem || (sender as! NSMenuItem).tag == 0
            await vm.getNotes(ifEmpty: ifEmpty, oneComplete: {
                self.tvWords.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
            }, allComplete: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // self.tableView.reloadData()
                }
            })
        }
    }

    @IBAction func clearNote(_ sender: AnyObject) {
        Task {
            let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
            await vm.clearNote(index: tvWords.selectedRow)
            tvWords.reloadData(forRowIndexes: [tvWords.selectedRow], columnIndexes: [col])
        }
    }

    @IBAction func clearNotes(_ sender: AnyObject) {
        Task {
            let ifEmpty = sender is NSToolbarItem || (sender as! NSMenuItem).tag == 0
            await vm.clearNotes(ifEmpty: ifEmpty, oneComplete: {
                self.tvWords.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // self.tableView.reloadData()
            }
        }
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        Task {
            await vmSettings.previousUnitPart()
            await vm.reload()
        }
    }

    @IBAction func nextUnitPart(_ sender: AnyObject) {
        Task {
            await vmSettings.nextUnitPart()
            await vm.reload()
        }
    }

    @IBAction func toggleToType(_ sender: AnyObject) {
        Task {
            let row = tvWords.selectedRow
            let part = row == -1 ? vmSettings.arrParts[0].value : arrWords[row].PART
            await vmSettings.toggleToType(part: part)
            await vm.reload()
        }
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words in \(vmSettings.UNITINFO)"
    }

    @IBAction func associateNewPhrase(_ sender: AnyObject) {
        guard vm.selectedWordID != 0 else {return}
        (NSApplication.shared.delegate as! AppDelegate).addNewUnitPhrase(wordid: vm.selectedWordID)
    }

    @IBAction func associateExistingPhrases(_ sender: AnyObject) {
        guard vm.selectedWordID != 0 else {return}
        let detailVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesAssociateViewController") as! PhrasesAssociateViewController
        detailVC.textFilter = vm.selectedWord
        detailVC.wordid = vm.selectedWordID
        detailVC.complete = {
            Task {
                await self.getPhrases()
            }
        }
        self.presentAsModalWindow(detailVC)
    }
}

class WordsUnitWindowController: WordsBaseWindowController {
}
