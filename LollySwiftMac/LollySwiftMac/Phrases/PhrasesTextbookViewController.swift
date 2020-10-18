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

class PhrasesTextbookViewController: PhrasesBaseViewController {
    
    var vm: PhrasesUnitViewModel!
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPhrases: [MUnitPhrase] { vm.arrPhrasesFiltered ?? vm.arrPhrases }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = PhrasesUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: false, needCopy: true) {
            self.wc.acTextbooks.content = self.vmSettings.arrTextbookFilters
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
        arrPhrases.count
    }
    
    override func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }
    
    override func endEditing(row: Int) {
        let item = arrPhrases[row]
        vm.update(item: item).subscribe(onNext: {_ in 
            self.tvPhrases.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPhrases.tableColumns.count))
        }) ~ rx.disposeBag
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

    @IBAction func editPhrase(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesTextbookDetailViewController") as! PhrasesTextbookDetailViewController
        let i = tvPhrases.selectedRow
        if i == -1 {return}
        editVC.startEdit(vm: vm, item: arrPhrases[i])
        editVC.complete = {
            self.tvPhrases.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvPhrases.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
    }
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        let n = wc.scTextFilter.selectedSegment
        vm.applyFilters(textFilter: wc.textFilter, scope: n == 0 ? "Phrase" : "Translation", textbookFilter: wc.textbookFilter)
        self.tvPhrases.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases in \(vmSettings.LANGINFO)"
    }
}

class PhrasesTextbookWindowController: PhrasesBaseWindowController {
}
