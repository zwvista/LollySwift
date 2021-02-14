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
import NSObject_Rx

class PhrasesUnitViewController: PhrasesBaseViewController, NSToolbarItemValidation {
    
    @objc var vm: PhrasesUnitViewModel!
    override var vmPhrases: PhrasesBaseViewModel { vm }
    var vmReview = EmbeddedReviewViewModel()
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPhrases: [MUnitPhrase] { vm.arrPhrasesFiltered ?? vm.arrPhrases }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        tvPhrases.registerForDraggedTypes([tableRowDragType])
    }
    
    // https://stackoverflow.com/questions/8017822/how-to-enable-disable-nstoolbaritem
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        let s = item.paletteLabel
        let enabled = !((s == "Previous" || s == "Next" || s == "U <-> P") && vmSettings.toType == .to)
        return enabled
    }

    override func settingsChanged() {
        vm = PhrasesUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: true, needCopy: true) {
            self.doRefresh()
        }
        super.settingsChanged()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPhrases ? arrPhrases.count : vmWordsLang.arrWords.count
    }
    
    override func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }
    
    override func endEditing(row: Int) {
        let item = arrPhrases[row]
        vm.update(item: item).subscribe(onNext: {_ in
            self.tvPhrases.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPhrases.tableColumns.count))
        }) ~ rx.disposeBag
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
        vm.reindex {
            tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
        }
        tableView.endUpdates()
        
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
        batchVC.vm = vm
        let i = tvPhrases.selectedRow
        let item = i == -1 ? nil : arrPhrases[tvPhrases.selectedRow]
        batchVC.unit = item?.UNIT ?? vmSettings.USUNITTO
        batchVC.part = item?.PART ?? vmSettings.USPARTTO
        batchVC.complete = { self.doRefresh() }
        self.presentAsModalWindow(batchVC)
    }

    override func deletePhrase(row: Int) {
        let item = arrPhrases[row]
        PhrasesUnitViewModel.delete(item: item).subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }
    
    @IBAction func doubleAction(_ sender: AnyObject) {
        if NSApp.currentEvent!.modifierFlags.contains(.option) {
            linkWords(sender)
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
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        vm.applyFilters(textFilter: vm.textFilter.value, scope: scScopeFilter.selectedSegment == 0 ? "Phrase" : "Translation", textbookFilter: 0)
        tvPhrases.reloadData()
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vmSettings.previousUnitPart().concat(vm.reload()).subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }
    
    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vmSettings.nextUnitPart().concat(vm.reload()).subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }
    
    @IBAction func toggleToType(_ sender: AnyObject) {
        let row = tvPhrases.selectedRow
        let part = row == -1 ? vmSettings.arrParts[0].value : arrPhrases[row].PART
        vmSettings.toggleToType(part: part).concat(vm.reload()).subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases in \(vmSettings.UNITINFO)"
    }
    
    @IBAction func reviewPhrases(_ sender: AnyObject) {
        vmReview.stop()
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.options = vmReview.options
        optionsVC.complete = { [unowned self] in
            var arrPhrases = self.arrPhrases
            if self.vmReview.options.shuffled {
                arrPhrases = arrPhrases.shuffled()
            }
            let arrIDs = arrPhrases.map(\.ID)
            self.vmReview.start(arrIDs: arrIDs, interval: self.vmReview.options.interval) { [unowned self] i in
                if let row = self.arrPhrases.firstIndex(where: { $0.ID == arrIDs[i] }) {
                    self.tvPhrases.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                }
            }
        }
        self.presentAsSheet(optionsVC)
    }

    @IBAction func linkWords(_ sender: AnyObject) {
        guard vm.selectedPhraseID != 0 else {return}
        let detailVC = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsLinkViewController") as! WordsLinkViewController
        detailVC.textFilter = vm.selectedPhrase
        detailVC.phraseid = vm.selectedPhraseID
        detailVC.complete = {
            self.getWords()
        }
        self.presentAsModalWindow(detailVC)
    }
}

class PhrasesUnitWindowController: PhrasesBaseWindowController {
}
