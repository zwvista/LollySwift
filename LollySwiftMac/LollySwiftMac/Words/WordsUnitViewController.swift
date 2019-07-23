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

class WordsUnitViewController: WordsBaseViewController, NSMenuItemValidation, NSToolbarItemValidation {

    var vm: WordsUnitViewModel!
    var vmReview: EmbeddedReviewViewModel!
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrWords: [MUnitWord] {
        return vm.arrWordsFiltered ?? vm.arrWords
    }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        vmReview = EmbeddedReviewViewModel(disposeBag: disposeBag)
        self.tableView.registerForDraggedTypes([tableRowDragType])
    }
    
    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(self.getNote(_:)) || menuItem.action == #selector(self.getNotes(_:)) {
            return vmSettings.hasDictNote
        }
        return true
    }

    // https://stackoverflow.com/questions/8017822/how-to-enable-disable-nstoolbaritem
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        let s = item.paletteLabel
        let enabled = !((s == "Previous" || s == "Next") && vmSettings.toType == .to || s == "Notes" && !vmSettings.hasDictNote)
        return enabled
    }

    override func settingsChanged() {
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: true, disposeBag: disposeBag, needCopy: true) {
            self.refreshTableView(self)
        }
        super.settingsChanged()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrWords.count
    }
    
    override func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        return arrWords[row]
    }

    override func levelChanged(row: Int) -> Observable<Int> {
        let item = arrWords[row]
        return MWordFami.update(wordid: item.WORDID, level: item.LEVEL).map { 1 }
    }
    
    override func endEditing(row: Int) {
        let item = arrWords[row]
        WordsUnitViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
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
        let col = tableView.tableColumns.firstIndex { $0.title == "SEQNUM" }!
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
        WordsUnitViewModel.create(item: item).subscribe(onNext: {
            item.ID = $0
            self.vm.arrWords.append(item)
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(IndexSet(integer: self.arrWords.count - 1), byExtendingSelection: false)
            self.responder = self.tfNewWord
        }).disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newUnitWord()
        detailVC.complete = { self.tableView.reloadData(); self.addWord(self) }
        self.presentAsSheet(detailVC)
    }
    
    override func deleteWord(row: Int) {
        let item = arrWords[row]
        WordsUnitViewModel.delete(item: item).subscribe{
            self.refreshTableView(self)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        tableView.reloadData()
        updateStatusText()
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = MUnitWord()
        detailVC.item.copy(from: arrWords[i])
        detailVC.complete = {
            self.arrWords[i].copy(from: detailVC.item)
            self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }
  
    @IBAction func batchEdit(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitBatchViewController") as! WordsUnitBatchViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        let item = i == -1 ? nil : arrWords[tableView.selectedRow]
        detailVC.unit = item?.UNIT ?? vmSettings.USUNITTO
        detailVC.part = item?.PART ?? vmSettings.USPARTTO
        detailVC.complete = { self.refreshTableView(self) }
        self.presentAsModalWindow(detailVC)
    }

    @IBAction func getNote(_ sender: AnyObject) {
        let col = tableView.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.getNote(index: tableView.selectedRow).subscribe {
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }

    @IBAction func getNotes(_ sender: AnyObject) {
        let ifEmpty = sender is NSToolbarItem || (sender as! NSMenuItem).tag == 0
        vm.getNotes(ifEmpty: ifEmpty, oneComplete: {
            self.tableView.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }, allComplete: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func clearNote(_ sender: AnyObject) {
        let col = tableView.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.clearNote(index: tableView.selectedRow).subscribe {
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }
    
    @IBAction func clearNotes(_ sender: AnyObject) {
        let ifEmpty = sender is NSToolbarItem || (sender as! NSMenuItem).tag == 0
        vm.clearNotes(ifEmpty: ifEmpty, oneComplete: {
            self.tableView.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }).subscribe {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // self.tableView.reloadData()
            }
        }.disposed(by: disposeBag)
    }

    @IBAction func filterWord(_ sender: AnyObject) {
        let n = scTextFilter.selectedSegment
        vm.applyFilters(textFilter: n == 0 ? "" : textFilter, scope: n == 1 ? "Word" : "Note", levelge0only: levelge0only, textbookFilter: 0)
        self.tableView.reloadData()
    }
    
    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vmSettings.previousUnitPart().concat(vm.reload()).subscribe {
            self.refreshTableView(self)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vmSettings.nextUnitPart().concat(vm.reload()).subscribe {
            self.refreshTableView(self)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func toggleToType(_ sender: AnyObject) {
        let row = tableView.selectedRow
        let part = row == -1 ? vmSettings.arrParts[0].value : arrWords[row].PART
        vmSettings.toggleToType(part: part).concat(vm.reload()).subscribe {
            self.refreshTableView(self)
        }.disposed(by: disposeBag)
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Words in \(vmSettings.UNITINFO)"
    }
    
    @IBAction func reviewWords(_ sender: AnyObject) {
        if vmReview.subscription != nil {
            vmReview.stop()
        } else {
            let optionsVC = NSStoryboard(name: "Tools", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
            optionsVC.options.mode = 0
            optionsVC.options.shuffled = vmReview.shuffled
            optionsVC.options.levelge0only = vmReview.levelge0only
            optionsVC.complete = { [unowned self] in
                self.vmReview.shuffled = optionsVC.options.shuffled
                self.vmReview.levelge0only = optionsVC.options.levelge0only!
                var arrWords = self.arrWords
                if self.vmReview.levelge0only {
                    arrWords = arrWords.filter { $0.LEVEL >= 0 }
                }
                if self.vmReview.shuffled {
                    arrWords = arrWords.shuffled()
                }
                let arrIDs = arrWords.map{ $0.ID }
                self.vmReview.start(arrIDs: arrIDs, interval: Double(self.vmSettings.USSCANINTERVAL) / 1000.0) { [unowned self] i in
                    if let row = self.arrWords.firstIndex(where: { $0.ID == arrIDs[i] }) {
                        self.tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                    }
                }
            }
            self.presentAsSheet(optionsVC)
        }
    }
}

class WordsUnitWindowController: WordsBaseWindowController {
}
