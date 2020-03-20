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

class WordsTextbookViewController: WordsBaseViewController, NSMenuItemValidation {

    var vm: WordsUnitViewModel!
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrWords: [MUnitWord] {
        return vm.arrWordsFiltered == nil ? vm.arrWords : vm.arrWordsFiltered!
    }
    
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @objc var textbookFilter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: false, disposeBag: disposeBag, needCopy: true) {
            self.acTextbooks.content = self.vmSettings.arrTextbookFilters
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
            self.tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }.disposed(by: disposeBag)
    }
    
    override func searchPhrases() {
        vm.searchPhrases(wordid: selectedWordID).subscribe {
            self.tvPhrases.reloadData()
        }.disposed(by: disposeBag)
    }

    override func deleteWord(row: Int) {
        let item = arrWords[row]
        WordsUnitViewModel.delete(item: item).subscribe{
            self.doRefresh()
        }.disposed(by: disposeBag)
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe {
            self.doRefresh()
        }.disposed(by: disposeBag)
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsTextbookDetailViewController") as! WordsTextbookDetailViewController
        detailVC.vm = vm
        let i = tvWords.selectedRow
        detailVC.item = MUnitWord()
        detailVC.item.copy(from: arrWords[i])
        detailVC.complete = {
            self.arrWords[i].copy(from: detailVC.item)
            self.tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func getNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.getNote(index: tvWords.selectedRow).subscribe {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }
    
    @IBAction func clearNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.clearNote(index: tvWords.selectedRow).subscribe {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(getNote(_:)) {
            return vmSettings.hasDictNote
        }
        return true
    }

    @IBAction func filterWord(_ sender: AnyObject) {
        vm.applyFilters(textFilter: textFilter, scope: scTextFilter.selectedSegment == 0 ? "Word" : "Note", levelge0only: levelge0only, textbookFilter: textbookFilter)
        self.tvWords.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words in \(vmSettings.LANGINFO)"
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

class WordsTextbookWindowController: WordsBaseWindowController {
}
