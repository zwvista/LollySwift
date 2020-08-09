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

    var vm: WordsUnitViewModel!
    var vmReview = EmbeddedReviewViewModel()
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrWords: [MUnitWord] { vm.arrWordsFiltered ?? vm.arrWords }
    override var arrPhrases: [MLangPhrase] { vm.arrPhrases }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        vmReview.options.levelge0only = true
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
        tableView === tvWords ? arrWords.count : arrPhrases.count
    }
    
    override func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }

    override func levelChanged(row: Int) -> Observable<Int> {
        let item = arrWords[row]
        return MWordFami.update(wordid: item.WORDID, level: item.LEVEL).map { 1 }
    }
    
    override func endEditing(row: Int) {
        let item = arrWords[row]
        vm.update(item: item).subscribe {
            self.tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        } ~ rx.disposeBag
    }
    
    override func searchPhrases() {
        vm.searchPhrases(wordid: selectedWordID).subscribe {
            self.tvPhrases.reloadData()
        } ~ rx.disposeBag
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
            vm.moveWord(at: oldIndex, to: newIndex)
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
        guard !newWord.isEmpty else {return}
        let item = vm.newUnitWord()
        item.WORD = vmSettings.autoCorrectInput(text: newWord)
        tfNewWord.stringValue = ""
        newWord = ""
        vm.create(item: item).subscribe {
            self.vm.arrWords.append(item)
            self.tvWords.reloadData()
            self.tvWords.selectRowIndexes(IndexSet(integer: self.arrWords.count - 1), byExtendingSelection: false)
            self.responder = self.tfNewWord
        } ~ rx.disposeBag
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitEditViewController") as! WordsUnitEditViewController
        editVC.vm = vm
        editVC.item = vm.newUnitWord()
        editVC.complete = { self.tvWords.reloadData(); self.addWord(self) }
        self.presentAsSheet(editVC)
    }
    
    override func deleteWord(row: Int) {
        let item = arrWords[row]
        WordsUnitViewModel.delete(item: item).subscribe{
            self.doRefresh()
        } ~ rx.disposeBag
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe {
            self.doRefresh()
        } ~ rx.disposeBag
    }
    
    @IBAction func doubleAction(_ sender: AnyObject) {
        if NSApp.currentEvent!.modifierFlags.contains(.option) {
            selectPhrases(sender)
        } else {
            editWord(sender)
        }
    }
    
    @IBAction func editWord(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitEditViewController") as! WordsUnitEditViewController
        editVC.vm = vm
        let i = tvWords.selectedRow
        editVC.item = arrWords[i]
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
        vm.getNote(index: tvWords.selectedRow).subscribe {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        } ~ rx.disposeBag
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
        vm.clearNote(index: tvWords.selectedRow).subscribe {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        } ~ rx.disposeBag
    }
    
    @IBAction func clearNotes(_ sender: AnyObject) {
        let ifEmpty = sender is NSToolbarItem || (sender as! NSMenuItem).tag == 0
        vm.clearNotes(ifEmpty: ifEmpty, oneComplete: {
            self.tvWords.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }).subscribe {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // self.tableView.reloadData()
            }
        } ~ rx.disposeBag
    }

    @IBAction func filterWord(_ sender: AnyObject) {
        vm.applyFilters(textFilter: textFilter, scope: scTextFilter.selectedSegment == 0 ? "Word" : "Note", levelge0only: levelge0only, textbookFilter: 0)
        self.tvWords.reloadData()
    }
    
    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vmSettings.previousUnitPart().concat(vm.reload()).subscribe {
            self.doRefresh()
        } ~ rx.disposeBag
    }
    
    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vmSettings.nextUnitPart().concat(vm.reload()).subscribe {
            self.doRefresh()
        } ~ rx.disposeBag
    }
    
    @IBAction func toggleToType(_ sender: AnyObject) {
        let row = tvWords.selectedRow
        let part = row == -1 ? vmSettings.arrParts[0].value : arrWords[row].PART
        vmSettings.toggleToType(part: part).concat(vm.reload()).subscribe {
            self.doRefresh()
        } ~ rx.disposeBag
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words in \(vmSettings.UNITINFO)"
    }
    
    @IBAction func reviewWords(_ sender: AnyObject) {
        vmReview.stop()
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.options.copy(from: vmReview.options)
        optionsVC.complete = { [unowned optionsVC] in
            self.vmReview.options.copy(from: optionsVC.options)
            var arrWords = self.arrWords
            if self.vmReview.options.levelge0only! {
                arrWords = arrWords.filter { $0.LEVEL >= 0 }
            }
            if self.vmReview.options.shuffled {
                arrWords = arrWords.shuffled()
            }
            let arrIDs = arrWords.map { $0.ID }
            self.vmReview.start(arrIDs: arrIDs, interval: self.vmReview.options.interval) { [unowned self] i in
                if let row = self.arrWords.firstIndex(where: { $0.ID == arrIDs[i] }) {
                    self.tvWords.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                }
            }
        }
        self.presentAsSheet(optionsVC)
    }

    @IBAction func selectPhrases(_ sender: AnyObject) {
        guard selectedWordID != 0 else {return}
        let detailVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesSelectUnitViewController") as! PhrasesSelectUnitViewController
        detailVC.textFilter = selectedWord
        detailVC.wordid = selectedWordID
        detailVC.complete = {
            self.searchPhrases()
        }
        self.presentAsModalWindow(detailVC)
    }
}

class WordsUnitWindowController: WordsBaseWindowController {
}
