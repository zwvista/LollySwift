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

    var vm: PhrasesUnitViewModel!
    override var vmPhrases: PhrasesBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPhrases: [MUnitPhrase] { vm.arrPhrasesFiltered }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        tvPhrases.registerForDraggedTypes([tableRowDragType])
        vm.$arrPhrasesFiltered.didSet.sink { [unowned self] _ in
            self.doRefresh()
        } ~ subscriptions
    }

    // https://stackoverflow.com/questions/8017822/how-to-enable-disable-nstoolbaritem
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        let s = item.paletteLabel
        let enabled = !((s == "Previous" || s == "Next" || s == "U <-> P") && vmSettings.toType == .to)
        return enabled
    }

    override func settingsChanged() {
        vm = PhrasesUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: true, needCopy: true) {}
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPhrases ? arrPhrases.count : vmWordsLang.arrWords.count
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
        if vmSettings.isSingleUnitPart && vm.arrPhrasesFiltered == nil {
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
            vm.arrPhrases.moveElement(at: oldIndex, to: newIndex)
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

    func addPhrase(wordid: Int) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
        editVC.startEdit(vm: vm, item: vm.newUnitPhrase(), wordid: wordid)
        editVC.complete = { self.tvPhrases.reloadData(); self.addPhrase(self) }
        self.presentAsSheet(editVC)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: AnyObject) {
        addPhrase(wordid: 0)
    }

    @IBAction func batchAdd(_ sender: AnyObject) {
        let batchVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitBatchAddViewController") as! PhrasesUnitBatchAddViewController
        batchVC.startEdit(vm: vm)
        batchVC.complete = { self.doRefresh() }
        self.presentAsModalWindow(batchVC)
    }

    @IBAction func batchEdit(_ sender: AnyObject) {
        let batchVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitBatchEditViewController") as! PhrasesUnitBatchEditViewController
        let i = tvPhrases.selectedRow
        let item = i == -1 ? nil : arrPhrases[tvPhrases.selectedRow]
        batchVC.startEdit(vm: vm, unit: item?.UNIT ?? vmSettings.USUNITTO, part: item?.PART ?? vmSettings.USPARTTO)
        batchVC.complete = { self.doRefresh() }
        self.presentAsModalWindow(batchVC)
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
        let editVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
        let i = tvPhrases.selectedRow
        if i == -1 {return}
        editVC.startEdit(vm: vm, item: arrPhrases[i], wordid: 0)
        editVC.complete = {
            self.tvPhrases.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvPhrases.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
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
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases in \(vmSettings.UNITINFO)"
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
        detailVC.complete = {
            Task {
                await self.getWords()
            }
        }
        self.presentAsModalWindow(detailVC)
    }

    @IBAction func generateBlogContent(_ sender: AnyObject) {
        let s = vm.arrPhrases.map { "* \($0.PHRASE)：\($0.TRANSLATION)：\n"}.joined(separator: "")
        MacApi.copyText(s)
    }
}

class PhrasesUnitWindowController: PhrasesBaseWindowController {
}
