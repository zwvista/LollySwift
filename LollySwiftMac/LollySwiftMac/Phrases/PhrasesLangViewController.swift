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

class PhrasesLangViewController: PhrasesBaseViewController {

    var vm: PhrasesLangViewModel!
    override var vmPhrases: PhrasesBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPhrases: [MLangPhrase] { vm.arrPhrasesFiltered }

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.$arrPhrasesFiltered.didSet.sink { [unowned self] _ in
            self.doRefresh()
        } ~ subscriptions
    }

    override func settingsChanged() {
        vm = PhrasesLangViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {}
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPhrases ? arrPhrases.count : vmWordsLang.arrWords.count
    }

    override func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }

    override func endEditing(row: Int) {
        Task {
            let item = arrPhrases[row]
            await PhrasesLangViewModel.update(item: item)
        }
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vmEdit = PhrasesLangDetailViewModel(vm: vm, item: vm.newLangPhrase())
        detailVC.complete = { self.tvPhrases.reloadData(); self.addPhrase(self) }
        self.presentAsSheet(detailVC)
    }

    override func deletePhrase(row: Int) {
        Task {
            await PhrasesLangViewModel.delete(item: arrPhrases[row])
            doRefresh()
        }
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        Task {
            await vm.reload()
            doRefresh()
        }
    }

    @IBAction func doubleAction(_ sender: AnyObject) {
        if NSApp.currentEvent!.modifierFlags.contains(.option) {
            associateWords(sender)
        } else {
            editPhrase(sender)
        }
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        let i = tvPhrases.selectedRow
        detailVC.vmEdit = PhrasesLangDetailViewModel(vm: vm, item: arrPhrases[i])
        detailVC.complete = {
            self.tvPhrases.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvPhrases.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
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
            Task {
                await self.getWords()
            }
        }
        self.presentAsModalWindow(detailVC)
    }
}

class PhrasesLangWindowController: PhrasesBaseWindowController {
}

