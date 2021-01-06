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

class WordsUnitViewController: WordsBaseViewController, NSMenuItemValidation, NSToolbarItemValidation {

    @objc var vm: WordsUnitViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    var vmReview = EmbeddedReviewViewModel()
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrWords: [MUnitWord] { vm.arrWordsFiltered ?? vm.arrWords }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        tvWords.registerForDraggedTypes([tableRowDragType])
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
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: true, needCopy: true) {
            self.doRefresh()
        }
        super.settingsChanged()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvWords ? arrWords.count : vmPhrasesLang.arrPhrases.count
    }
    
    override func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }
    
    override func endEditing(row: Int) {
        let item = arrWords[row]
        vm.update(item: item).subscribe(onNext: {_ in 
            self.tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }) ~ rx.disposeBag
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
        vm.reindex {
            tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
        }
        tableView.endUpdates()
        
        return true
    }
    
    override func addNewWord() {
        guard !vm.newWord.isEmpty else {return}
        let item = vm.newUnitWord()
        item.WORD = vmSettings.autoCorrectInput(text: vm.newWord)
        tfNewWord.stringValue = ""
        vm.newWord = ""
        vm.create(item: item).subscribe(onNext: {_ in
            self.tvWords.reloadData()
            self.tvWords.selectRowIndexes(IndexSet(integer: self.arrWords.count - 1), byExtendingSelection: false)
            self.responder = self.tfNewWord
        }) ~ rx.disposeBag
    }
    
    func addWord(phraseid: Int) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        editVC.startEdit(vm: vm, item: vm.newUnitWord(), phraseid: phraseid)
        editVC.complete = { self.tvWords.reloadData(); self.addWord(self) }
        self.presentAsSheet(editVC)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: AnyObject) {
        addWord(phraseid: 0)
    }
    
    override func deleteWord(row: Int) {
        let item = arrWords[row]
        WordsUnitViewModel.delete(item: item).subscribe(onNext: {
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
            linkPhrases(sender)
        } else {
            editWord(sender)
        }
    }
    
    @IBAction func editWord(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        let i = tvWords.selectedRow
        if i == -1 {return}
        editVC.startEdit(vm: vm, item: arrWords[tvWords.selectedRow], phraseid: 0)
        editVC.complete = {
            self.tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
    }
  
    @IBAction func batchEdit(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitBatchViewController") as! WordsUnitBatchViewController
        detailVC.vm = vm
        let i = tvWords.selectedRow
        let item = i == -1 ? nil : arrWords[tvWords.selectedRow]
        detailVC.unit = item?.UNIT ?? vmSettings.USUNITTO
        detailVC.part = item?.PART ?? vmSettings.USPARTTO
        detailVC.complete = { self.doRefresh() }
        self.presentAsModalWindow(detailVC)
    }

    @IBAction func getNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.getNote(index: tvWords.selectedRow).subscribe(onNext: {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        }) ~ rx.disposeBag
    }

    @IBAction func getNotes(_ sender: AnyObject) {
        let ifEmpty = sender is NSToolbarItem || (sender as! NSMenuItem).tag == 0
        vm.getNotes(ifEmpty: ifEmpty, oneComplete: {
            self.tvWords.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }, allComplete: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func clearNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.clearNote(index: tvWords.selectedRow).subscribe(onNext: {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        }) ~ rx.disposeBag
    }
    
    @IBAction func clearNotes(_ sender: AnyObject) {
        let ifEmpty = sender is NSToolbarItem || (sender as! NSMenuItem).tag == 0
        vm.clearNotes(ifEmpty: ifEmpty, oneComplete: {
            self.tvWords.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }).subscribe(onNext: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // self.tableView.reloadData()
            }
        }) ~ rx.disposeBag
    }

    @IBAction func filterWord(_ sender: AnyObject) {
        vm.applyFilters(textFilter: vm.textFilter, scope: scScopeFilter.selectedSegment == 0 ? "Word" : "Note", textbookFilter: 0)
        tvWords.reloadData()
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
        let row = tvWords.selectedRow
        let part = row == -1 ? vmSettings.arrParts[0].value : arrWords[row].PART
        vmSettings.toggleToType(part: part).concat(vm.reload()).subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words in \(vmSettings.UNITINFO)"
    }
    
    @IBAction func reviewWords(_ sender: AnyObject) {
        vmReview.stop()
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.options = vmReview.options
        optionsVC.complete = { [unowned self] in
            var arrWords = self.arrWords
            if self.vmReview.options.shuffled {
                arrWords = arrWords.shuffled()
            }
            let arrIDs = arrWords.map(\.ID)
            self.vmReview.start(arrIDs: arrIDs, interval: self.vmReview.options.interval) { [unowned self] i in
                if let row = self.arrWords.firstIndex(where: { $0.ID == arrIDs[i] }) {
                    self.tvWords.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                }
            }
        }
        self.presentAsSheet(optionsVC)
    }

    @IBAction func linkPhrases(_ sender: AnyObject) {
        guard vm.selectedWordID != 0 else {return}
        let detailVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesLinkViewController") as! PhrasesLinkViewController
        detailVC.textFilter = vm.selectedWord
        detailVC.wordid = vm.selectedWordID
        detailVC.complete = {
            self.getPhrases()
        }
        self.presentAsModalWindow(detailVC)
    }
}

class WordsUnitWindowController: WordsBaseWindowController {
}
