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

class WordsTextbookViewController: WordsBaseViewController, NSMenuItemValidation {

    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet var acTextbooks: NSArrayController!

    var vm: WordsUnitViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    var arrWords: [MUnitWord] { vm.arrWords }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = WordsUnitViewModel(inTextbook: false)
        refreshTableView(self)
        acTextbooks.content = vmSettings.arrTextbookFilters
        vm.$arrWords.didSet.sink { [unowned self] _ in
            doRefresh()
        } ~ subscriptions
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvWords ? arrWords.count : vmPhrasesLang.arrPhrasesAll.count
    }

    override func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }

    override func endEditing(row: Int) {
        Task {
            let item = arrWords[row]
            await vm.update(item: item)
            tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<tvWords.tableColumns.count))
        }
    }

    override func deleteWord(row: Int) {
        Task {
            let item = arrWords[row]
            await WordsUnitViewModel.delete(item: item)
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
            associatePhrases(sender)
        } else {
            editWord(sender)
        }
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "WordsTextbookDetailViewController") as! WordsTextbookDetailViewController
        let i = tvWords.selectedRow
        if i == -1 {return}
        detailVC.vmEdit = WordsUnitDetailViewModel(vm: vm, item: arrWords[i], phraseid: 0)
        detailVC.complete = { [unowned self] in
            tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvWords.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func getNote(_ sender: AnyObject) {
        Task {
            let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
            await vm.getNote(index: tvWords.selectedRow)
            tvWords.reloadData(forRowIndexes: [tvWords.selectedRow], columnIndexes: [col])
        }
    }

    @IBAction func clearNote(_ sender: AnyObject) {
        Task {
            let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
            await vm.clearNote(index: tvWords.selectedRow)
            tvWords.reloadData(forRowIndexes: [tvWords.selectedRow], columnIndexes: [col])
        }
    }

    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(getNote(_:)) {
            return vmSettings.hasDictNote
        }
        return true
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words in \(vmSettings.LANGINFO)"
    }

    @IBAction func associatePhrases(_ sender: AnyObject) {
        guard vm.selectedWordID != 0 else {return}
        let detailVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesAssociateViewController") as! PhrasesAssociateViewController
        detailVC.textFilter = vm.selectedWord
        detailVC.wordid = vm.selectedWordID
        detailVC.complete = { [unowned self] in
            Task {
                await getPhrases()
            }
        }
        presentAsModalWindow(detailVC)
    }
}
