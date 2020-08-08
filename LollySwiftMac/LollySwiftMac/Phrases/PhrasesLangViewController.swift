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

class PhrasesLangViewController: PhrasesBaseViewController {
    
    var vm: PhrasesLangViewModel!
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPhrases: [MLangPhrase] { vm.arrPhrasesFiltered ?? vm.arrPhrases }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func settingsChanged() {
        vm = PhrasesLangViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
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
        PhrasesLangViewModel.update(item: item).subscribe() ~ rx.disposeBag
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
        PhrasesLangViewModel.delete(item: arrPhrases[row]).subscribe {
            self.doRefresh()
        } ~ rx.disposeBag
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe {
            self.doRefresh()
        } ~ rx.disposeBag
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = MLangPhrase()
        detailVC.item.copy(from: arrPhrases[i])
        detailVC.complete = { [unowned detailVC] in
            self.arrPhrases[i].copy(from: detailVC.item)
            self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        let n = wc.scTextFilter.selectedSegment
        vm.applyFilters(textFilter: wc.textFilter, scope: n == 0 ? "Phrase" : "Translation")
        tableView.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Phrases in \(vmSettings.LANGINFO)"
    }
}

class PhrasesLangWindowController: PhrasesBaseWindowController {
}

