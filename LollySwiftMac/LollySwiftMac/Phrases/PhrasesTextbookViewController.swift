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

    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet var acTextbooks: NSArrayController!

    var vm = PhrasesUnitViewModel(inTextbook: false)
    override var vmPhrases: PhrasesBaseViewModel { vm }
    var arrPhrases: [MUnitPhrase] { vm.arrPhrases }

    override func viewDidLoad() {
        super.viewDidLoad()
        acTextbooks.content = vmSettings.arrTextbookFilters
        vm.$arrPhrases.didSet.sink { [unowned self] _ in
            doRefresh()
        } ~ subscriptions
    }

    override func settingsChanged() {
        refreshTableView(self)
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPhrases ? arrPhrases.count : vmWordsLang.arrWordsAll.count
    }

    override func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }

    override func endEditing(row: Int) {
        Task {
            let item = arrPhrases[row]
            await vm.update(item: item)
            tvPhrases.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<tvPhrases.tableColumns.count))
        }
    }

    override func deletePhrase(row: Int) {
        Task {
            let item = arrPhrases[row]
            await PhrasesUnitViewModel.delete(item: item)
            doRefresh()
        }
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        Task {
            await vm.reload()
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
        let detailVC = storyboard!.instantiateController(withIdentifier: "PhrasesTextbookDetailViewController") as! PhrasesTextbookDetailViewController
        let i = tvPhrases.selectedRow
        if i == -1 {return}
        detailVC.vmEdit = PhrasesUnitDetailViewModel(vm: vm, item: arrPhrases[i], wordid: 0)
        detailVC.complete = { [unowned self] in
            tvPhrases.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvPhrases.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases in \(vmSettings.LANGINFO)"
    }

    @IBAction func associateWords(_ sender: AnyObject) {
        guard vm.selectedPhraseID != 0 else {return}
        let detailVC = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsAssociateViewController") as! WordsAssociateViewController
        detailVC.textFilter = vm.selectedPhrase
        detailVC.phraseid = vm.selectedPhraseID
        detailVC.complete = { [unowned self] in
            Task {
                await getWords()
            }
        }
        presentAsModalWindow(detailVC)
    }
}
