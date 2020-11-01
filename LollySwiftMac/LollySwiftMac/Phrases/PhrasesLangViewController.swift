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
    override var arrWords: [MLangWord] { vm.arrWords }

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
    
    override func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }
    
    override func endEditing(row: Int) {
        let item = arrPhrases[row]
        PhrasesLangViewModel.update(item: item).subscribe() ~ rx.disposeBag
    }
    
    override func searchWords() {
        vm.searchWords(phraseid: selectedPhraseID).subscribe(onNext: {
            self.tvWords.reloadData()
            if self.tvWords.numberOfRows > 0 {
                self.tvWords.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            }
        }) ~ rx.disposeBag
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        editVC.vm = vm
        editVC.item = vm.newLangPhrase()
        editVC.complete = { self.tvPhrases.reloadData(); self.addPhrase(self) }
        self.presentAsSheet(editVC)
    }

    override func deletePhrase(row: Int) {
        PhrasesLangViewModel.delete(item: arrPhrases[row]).subscribe(onNext: {
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
            linkWords(sender)
        } else {
            editPhrase(sender)
        }
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        editVC.vm = vm
        let i = tvPhrases.selectedRow
        editVC.item = arrPhrases[i]
        editVC.complete = {
            self.tvPhrases.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvPhrases.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
    }
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        vm.applyFilters(textFilter: textFilter, scope: scTextFilter.selectedSegment == 0 ? "Phrase" : "Translation")
        tvPhrases.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases in \(vmSettings.LANGINFO)"
    }

    @IBAction func linkWords(_ sender: AnyObject) {
        guard selectedPhraseID != 0 else {return}
        let detailVC = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsLinkViewController") as! WordsLinkViewController
        detailVC.textFilter = selectedPhrase
        detailVC.phraseid = selectedPhraseID
        detailVC.complete = {
            self.searchWords()
        }
        self.presentAsModalWindow(detailVC)
    }
}

class PhrasesLangWindowController: PhrasesBaseWindowController {
}

