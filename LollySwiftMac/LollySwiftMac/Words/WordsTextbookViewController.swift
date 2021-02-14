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

class WordsTextbookViewController: WordsBaseViewController, NSMenuItemValidation {

    @objc var vm: WordsUnitViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrWords: [MUnitWord] { vm.arrWordsFiltered == nil ? vm.arrWords : vm.arrWordsFiltered! }
    
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @objc var textbookFilter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        sfFilter.rx.textSearch.subscribe(onNext: { [unowned self] _ in self.filterWord(self) }) ~ rx.disposeBag
        scScopeFilter.rx.selectedLabel.subscribe(onNext: { [unowned self] _ in self.filterWord(self) }) ~ rx.disposeBag
    }

    override func settingsChanged() {
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: false, needCopy: true) {
            self.acTextbooks.content = self.vmSettings.arrTextbookFilters
            self.doRefresh()
        }
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
        vm.update(item: item).subscribe(onNext: {_ in 
            self.tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }) ~ rx.disposeBag
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
        let editVC = self.storyboard!.instantiateController(withIdentifier: "WordsTextbookDetailViewController") as! WordsTextbookDetailViewController
        let i = tvWords.selectedRow
        if i == -1 {return}
        editVC.startEdit(vm: vm, item: arrWords[i])
        editVC.complete = {
            self.tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
    }
    
    @IBAction func getNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.getNote(index: tvWords.selectedRow).subscribe(onNext: {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        }) ~ rx.disposeBag
    }
    
    @IBAction func clearNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.clearNote(index: tvWords.selectedRow).subscribe(onNext: {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        }) ~ rx.disposeBag
    }

    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(getNote(_:)) {
            return vmSettings.hasDictNote
        }
        return true
    }

    @IBAction func filterWord(_ sender: AnyObject) {
        vm.applyFilters()
        tvWords.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words in \(vmSettings.LANGINFO)"
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

class WordsTextbookWindowController: WordsBaseWindowController {
}
