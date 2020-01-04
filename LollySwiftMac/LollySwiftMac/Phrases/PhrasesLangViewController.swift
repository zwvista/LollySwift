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

class PhrasesLangViewController: PhrasesBaseViewController {
    
    var vm: PhrasesLangViewModel!
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrPhrases: [MLangPhrase] {
        return vm.arrPhrasesFiltered ?? vm.arrPhrases
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func settingsChanged() {
        vm = PhrasesLangViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag, needCopy: true) {
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
        PhrasesLangViewModel.update(item: item).subscribe().disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newLangPhrase()
        detailVC.complete = { self.tableView.reloadData(); self.addPhrase(self) }
        self.presentAsSheet(detailVC)
    }

    override func deletePhrase(row: Int) {
        PhrasesLangViewModel.delete(arrPhrases[row].ID).subscribe {
            self.doRefresh()
        }.disposed(by: disposeBag)
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe {
            self.doRefresh()
        }.disposed(by: disposeBag)
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = MLangPhrase()
        detailVC.item.copy(from: arrPhrases[i])
        detailVC.complete = {
            self.arrPhrases[i].copy(from: detailVC.item)
            self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        let n = wc.scTextFilter.selectedSegment
        vm.applyFilters(textFilter: n == 0 ? "" : wc.textFilter, scope: n == 1 ? "Phrase" : "Translation")
        tableView.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Phrases in \(vmSettings.LANGINFO)"
    }
}

class PhrasesLangWindowController: PhrasesBaseWindowController {
    
    override func filterPhrase() {
        let vc = contentViewController as! PhrasesLangViewController
        textFilter = vc.vmSettings.autoCorrectInput(text: textFilter)
        tfFilter.stringValue = textFilter
        vc.filterPhrase(scTextFilter)
    }
}

