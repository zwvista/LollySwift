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
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrPhrases: [MUnitPhrase] {
        return vm.arrPhrasesFiltered ?? vm.arrPhrases
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = PhrasesUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: false, disposeBag: disposeBag, needCopy: true) {
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
        return arrPhrases.count
    }
    
    override func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        return arrPhrases[row]
    }
    
    override func endEditing(row: Int) {
        let item = arrPhrases[row]
        PhrasesUnitViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
    }

    override func deletePhrase(row: Int) {
        let item = arrPhrases[row]
        PhrasesUnitViewModel.delete(item: item).subscribe{
            self.doRefresh()
        }.disposed(by: disposeBag)
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe {
            self.doRefresh()
        }.disposed(by: disposeBag)
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesTextbookDetailViewController") as! PhrasesTextbookDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = MUnitPhrase()
        detailVC.item.copy(from: arrPhrases[i])
        detailVC.complete = {
            self.arrPhrases[i].copy(from: detailVC.item)
            self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        let n = wc.scTextFilter.selectedSegment
        vm.applyFilters(textFilter: n == 0 ? "" : wc.textFilter, scope: n == 1 ? "Phrase" : "Translation", textbookFilter: wc.textbookFilter)
        self.tableView.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Phrases in \(vmSettings.LANGINFO)"
    }
}

class PhrasesTextbookWindowController: PhrasesBaseWindowController {
    
    override func filterPhrase() {
        let vc = contentViewController as! PhrasesTextbookViewController
        textFilter = vc.vmSettings.autoCorrectInput(text: textFilter)
        tfFilter.stringValue = textFilter
        vc.filterPhrase(scTextFilter)
    }
}
