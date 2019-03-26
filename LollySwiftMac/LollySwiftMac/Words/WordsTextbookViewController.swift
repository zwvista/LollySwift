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
    var arrWords: [MUnitWord] {
        return vm.arrWordsFiltered == nil ? vm.arrWords : vm.arrWordsFiltered!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        refreshTableView(self)
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
    
    override func deleteWord(row: Int) {
        let item = arrWords[row]
        WordsUnitViewModel.delete(item: item).subscribe{
            self.refreshTableView(self)
        }.disposed(by: disposeBag)
    }

    @IBAction func refreshTableView(_ sender: Any) {
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: false, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editWord(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsTextbookDetailViewController") as! WordsTextbookDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = vm.arrWords[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func getNote(_ sender: Any) {
        let col = tableView.tableColumns.firstIndex(where: {$0.title == "NOTE"})!
        vm.getNote(index: tableView.selectedRow).subscribe {
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }
    
    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(self.getNote(_:)) {
            return vmSettings.hasNote
        }
        return true
    }

    @IBAction func filterWord(_ sender: Any) {
        let n = (sender as! NSSegmentedControl).selectedSegment
        if n == 0 {
            vm.arrWordsFiltered = nil
        } else {
            vm.filterWordsForSearchText(filterText, scope: "Word")
        }
        self.tableView.reloadData()
    }
}

class WordsTextbookWindowController: WordsBaseWindowController {
}
