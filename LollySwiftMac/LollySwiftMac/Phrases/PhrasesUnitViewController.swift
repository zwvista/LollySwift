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

class PhrasesUnitViewController: PhrasesBaseViewController, NSToolbarItemValidation {
    
    var vm: PhrasesUnitViewModel!
    var vmReview: EmbeddedReviewViewModel!
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrPhrases: [MUnitPhrase] {
        return vm.arrPhrasesFiltered == nil ? vm.arrPhrases : vm.arrPhrasesFiltered!
    }
    
    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        vmReview = EmbeddedReviewViewModel(disposeBag: disposeBag)
        tableView.registerForDraggedTypes([tableRowDragType])
    }
    
    // https://stackoverflow.com/questions/8017822/how-to-enable-disable-nstoolbaritem
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        let s = item.paletteLabel
        let enabled = !((s == "Previous" || s == "Next") && vmSettings.toType == .to)
        return enabled
    }

    override func settingsChanged() {
        vm = PhrasesUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: true, disposeBag: disposeBag, needCopy: true) {
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
        return arrPhrases.count
    }
    
    override func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        return arrPhrases[row]
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
            vm.movePhrase(at: oldIndex, to: newIndex)
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
    
    override func endEditing(row: Int) {
        let item = arrPhrases[row]
        PhrasesUnitViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newUnitPhrase()
        detailVC.complete = { self.tableView.reloadData(); self.addPhrase(self) }
        self.presentAsSheet(detailVC)
    }
    
    @IBAction func batchEdit(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitBatchViewController") as! PhrasesUnitBatchViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        let item = i == -1 ? nil : arrPhrases[tableView.selectedRow]
        detailVC.unit = item?.UNIT ?? vmSettings.USUNITTO
        detailVC.part = item?.PART ?? vmSettings.USPARTTO
        detailVC.complete = { self.refreshTableView(self) }
        self.presentAsModalWindow(detailVC)
    }

    override func deletePhrase(row: Int) {
        let item = arrPhrases[row]
        PhrasesUnitViewModel.delete(item: item).subscribe{
            self.refreshTableView(self)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        tableView.reloadData()
        updateStatusText()
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = arrPhrases[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        let n = wc.scTextFilter.selectedSegment
        vm.applyFilters(textFilter: n == 0 ? "" : wc.textFilter, scope: n == 1 ? "Phrase" : "Translation", textbookFilter: wc.textbookFilter)
        tableView.reloadData()
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
        let part = row == -1 ? vmSettings.arrParts[0].value : arrPhrases[row].PART
        vmSettings.toggleToType(part: part).concat(vm.reload()).subscribe {
            self.refreshTableView(self)
        }.disposed(by: disposeBag)
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Phrases in \(vmSettings.UNITINFO)"
    }
    
    @IBAction func reviewPhrases(_ sender: AnyObject) {
        if vmReview.subscription != nil {
            vmReview.stop()
        } else {
            let optionsVC = NSStoryboard(name: "Tools", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
            optionsVC.mode = 0
            optionsVC.shuffled = vmReview.shuffled
            optionsVC.complete = { [unowned self] in
                self.vmReview.shuffled = optionsVC.shuffled
                self.vmReview.levelge0only = optionsVC.levelge0only!
                var arrPhrases = self.arrPhrases
                if self.vmReview.shuffled {
                    arrPhrases = arrPhrases.shuffled()
                }
                let arrIDs = arrPhrases.map{ $0.ID }
                self.vmReview.start(arrIDs: arrIDs, interval: Double(self.vmSettings.USREADINTERVAL) / 1000.0) { [unowned self] i in
                    if let row = self.arrPhrases.firstIndex(where: { $0.ID == arrIDs[i] }) {
                        self.tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                    }
                }
            }
            self.presentAsSheet(optionsVC)
        }
    }
}

class PhrasesUnitWindowController: PhrasesBaseWindowController {
    
    override func filterPhrase() {
        let vc = contentViewController as! PhrasesUnitViewController
        textFilter = vc.vmSettings.autoCorrectInput(text: textFilter)
        tfFilter.stringValue = textFilter
        vc.filterPhrase(scTextFilter)
    }
}
