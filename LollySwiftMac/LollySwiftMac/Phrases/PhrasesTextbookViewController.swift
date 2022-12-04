//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import Combine

class PhrasesTextbookViewController: PhrasesBaseViewController {
    
    var vm: PhrasesUnitViewModel!
    override var vmPhrases: PhrasesBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPhrases: [MUnitPhrase] { vm.arrPhrasesFiltered ?? vm.arrPhrases }

    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    
    override func applyFilters() {
        vm.applyFilters()
        tvPhrases.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pubTextbookFilter.rx.selectedItemIndex.subscribe(onNext: { [unowned self] _ in self.applyFilters() }) ~ rx.disposeBag
    }

    override func settingsChanged() {
        vm = PhrasesUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: false, needCopy: true) {
            self.acTextbooks.content = self.vmSettings.arrTextbookFilters
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
        vm.update(item: item).subscribe(onSuccess: {
            self.tvPhrases.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPhrases.tableColumns.count))
        }) ~ rx.disposeBag
    }

    override func deletePhrase(row: Int) {
        let item = arrPhrases[row]
        PhrasesUnitViewModel.delete(item: item).subscribe(onSuccess: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe(onSuccess: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }
    
    @IBAction func doubleAction(_ sender: AnyObject) {
        if NSApp.currentEvent!.modifierFlags.contains(.option) {
            associateWords(sender)
        } else {
            editPhrase(sender)
        }
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

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases in \(vmSettings.LANGINFO)"
    }

    @IBAction func associateWords(_ sender: AnyObject) {
        guard vm.selectedPhraseID != 0 else {return}
        let detailVC = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsAssociateViewController") as! WordsAssociateViewController
        detailVC.textFilter = vm.selectedPhrase
        detailVC.phraseid = vm.selectedPhraseID
        detailVC.complete = {
            self.getWords()
        }
        self.presentAsModalWindow(detailVC)
    }
}

class PhrasesTextbookWindowController: PhrasesBaseWindowController {
}
