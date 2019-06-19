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

class WordsUnitViewController: WordsBaseViewController, NSMenuItemValidation {

    var vm: WordsUnitViewModel!
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrWords: [MUnitWord] {
        return vm.arrWordsFiltered ?? vm.arrWords
    }
    
    @IBOutlet weak var btnPrevious: NSButton!
    @IBOutlet weak var btnNext: NSButton!

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerForDraggedTypes([tableRowDragType])
    }

    override func settingsChanged() {
        refreshTableView(self)
        super.settingsChanged()
        let b = vmSettings.toType == 2
        btnPrevious.isEnabled = !b
        btnNext.isEnabled = !b
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
        if vm.vmSettings.isSingleUnitPart && vm.arrWordsFiltered == nil {
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
        let col = tableView.tableColumns.firstIndex(where: {$0.title == "SEQNUM"})!
        vm.reindex {
            tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
        }
        tableView.endUpdates()
        
        return true
    }
    
    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let item = vm.newUnitWord()
        item.WORD = vm.vmSettings.autoCorrectInput(text: newWord)
        self.tfNewWord.stringValue = ""
        self.newWord = ""
        WordsUnitViewModel.create(item: item).subscribe(onNext: {
            item.ID = $0
            self.vm.arrWords.append(item)
            self.tableView.reloadData()
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
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: true, disposeBag: disposeBag, needCopy: true) {
            self.tableView.reloadData()
            self.updateStatusText()
        }
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsUnitDetailViewController") as! WordsUnitDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = arrWords[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
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
        let col = tableView.tableColumns.firstIndex(where: {$0.title == "NOTE"})!
        vm.getNote(index: tableView.selectedRow).subscribe {
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }

    @IBAction func getNotes(_ sender: AnyObject) {
        let ifEmpty = (sender as! NSMenuItem).tag == 0
        vm.getNotes(ifEmpty: ifEmpty, oneComplete: {
            self.tableView.reloadData(forRowIndexes: [$0], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }, allComplete: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // self.tableView.reloadData()
            }
        })
    }
    
    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(self.getNote(_:)) || menuItem.action == #selector(self.getNotes(_:)) {
            return vmSettings.hasDictNote
        }
        return true
    }
    
    @IBAction func read(_ sender: AnyObject) {
        var i = 0
        let wordCount = arrWords.count
        var subscription: Disposable?
        subscription = Observable<Int>.interval(vmSettings.USREADINTERVAL.toDouble / 1000.0, scheduler: MainScheduler.instance).subscribe { _ in
            if i >= wordCount {
                subscription?.dispose()
            } else {
                self.synth.startSpeaking(self.arrWords[i].WORD)
                i += 1
            }
        }
        subscription?.disposed(by: disposeBag)
    }

    @IBAction func filterWord(_ sender: AnyObject) {
        let n = scTextFilter.selectedSegment
        vm.applyFilters(textFilter: n == 0 ? "" : textFilter, scope: n == 1 ? "Word" : "Note", levelge0only: levelge0only, textbookFilter: 0)
        self.tableView.reloadData()
    }
    
    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vmSettings.previousUnitPart().subscribe {
            self.settingsChanged()
            }.disposed(by: disposeBag)
    }
    
    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vmSettings.nextUnitPart().subscribe {
            self.settingsChanged()
            }.disposed(by: disposeBag)
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(vmSettings.selectedLang.LANGNAME) \(vmSettings.USUNITFROMSTR) \(vmSettings.USPARTFROMSTR) \(vmSettings.USUNITTOSTR) \(vmSettings.USPARTTOSTR) \(tableView.numberOfRows) Words "
    }
}

class WordsUnitWindowController: WordsBaseWindowController {
}
