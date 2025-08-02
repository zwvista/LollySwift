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

class PhrasesUnitViewController: PhrasesBaseViewController, NSToolbarItemValidation {

    var vm = PhrasesUnitViewModel(inTextbook: true)
    override var vmPhrases: PhrasesBaseViewModel { vm }
    var arrPhrases: [MUnitPhrase] { vm.arrPhrases }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        tvPhrases.registerForDraggedTypes([tableRowDragType])
        vm.$arrPhrases.didSet.sink { [unowned self] _ in
            doRefresh()
        } ~ subscriptions
    }

    // https://stackoverflow.com/questions/8017822/how-to-enable-disable-nstoolbaritem
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        let s = item.paletteLabel
        let enabled = !((s == "Previous" || s == "Next" || s == "U <-> P") && vmSettings.toType == .to)
        return enabled
    }

    override func settingsChanged() {
        refreshTableView(self)
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPhrases ? arrPhrases.count : vmWordsLang.arrWordsAll.count
    }

    override func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }

    override func endEditing(row: Int) {
        Task {
            let item = arrPhrases[row]
            await vm.update(item: item)
            tvPhrases.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<tvPhrases.tableColumns.count))
        }
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if vmSettings.isSingleUnitPart && !vm.hasFilter {
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
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { [unowned self] (draggingItem, _, _) in
            if let str = (draggingItem.item as! NSPasteboardItem).string(forType: tableRowDragType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }

        var oldIndexOffset = 0
        var newIndexOffset = 0

        func moveRow(at oldIndex: Int, to newIndex: Int) {
            vm.arrPhrasesAll.moveElement(at: oldIndex, to: newIndex)
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
        let col = tableView.tableColumns.firstIndex { $0.identifier.rawValue == "SEQNUM" }!
        Task {
            await vm.reindex {
                tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
            }
        }

        return true
    }

    func addPhrase(wordid: Int) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
        detailVC.vmEdit = PhrasesUnitDetailViewModel(vm: vm, item: vm.newUnitPhrase(), wordid: wordid)
        detailVC.complete = { [unowned self] in tvPhrases.reloadData(); addPhrase(self) }
        presentAsSheet(detailVC)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: AnyObject) {
        addPhrase(wordid: 0)
    }

    @IBAction func batchAdd(_ sender: AnyObject) {
        let batchVC = storyboard!.instantiateController(withIdentifier: "PhrasesUnitBatchAddViewController") as! PhrasesUnitBatchAddViewController
        batchVC.vmEdit = PhrasesUnitBatchAddViewModel(vm: vm)
        batchVC.complete = { [unowned self] in doRefresh() }
        presentAsModalWindow(batchVC)
    }

    @IBAction func batchEdit(_ sender: AnyObject) {
        let batchVC = storyboard!.instantiateController(withIdentifier: "PhrasesUnitBatchEditViewController") as! PhrasesUnitBatchEditViewController
        let i = tvPhrases.selectedRow
        let item = i == -1 ? nil : arrPhrases[tvPhrases.selectedRow]
        batchVC.vmEdit = PhrasesUnitBatchEditViewModel(vm: vm, unit: item?.UNIT ?? vmSettings.USUNITTO, part: item?.PART ?? vmSettings.USPARTTO)
        batchVC.complete = { [unowned self] in doRefresh() }
        presentAsModalWindow(batchVC)
    }

    override func deletePhrase(row: Int) {
        Task {
            let item = arrPhrases[row]
            await PhrasesUnitViewModel.delete(item: item)
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
            associateExistingWords(sender)
        } else {
            editPhrase(sender)
        }
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
        let i = tvPhrases.selectedRow
        if i == -1 {return}
        detailVC.vmEdit = PhrasesUnitDetailViewModel(vm: vm, item: arrPhrases[i], wordid: 0)
        detailVC.complete = { [unowned self] in
            tvPhrases.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvPhrases.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
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
        let row = tvPhrases.selectedRow
        let part = row == -1 ? vmSettings.arrParts[0].value : arrPhrases[row].PART
        Task {
            await vmSettings.toggleToType(part: part)
            await vm.reload()
        }
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases in \(vmSettings.UNITPARTINFO)"
    }

    @IBAction func associateNewWord(_ sender: AnyObject) {
        guard vm.selectedPhraseID != 0 else {return}
        (NSApplication.shared.delegate as! AppDelegate).addNewUnitWord(phraseid: vm.selectedPhraseID)
    }

    @IBAction func associateExistingWords(_ sender: AnyObject) {
        guard vm.selectedPhraseID != 0 else {return}
        let detailVC = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsAssociateViewController") as! WordsAssociateViewController
        detailVC.textFilter = vm.selectedPhrase
        detailVC.phraseid = vm.selectedPhraseID
        detailVC.complete = { [unowned self] in
            Task {
                await getWords()
            }
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func generateBlogContent(_ sender: AnyObject) {
        let s = vm.generateBlogContent()
        MacApi.copyText(s)
    }
}
