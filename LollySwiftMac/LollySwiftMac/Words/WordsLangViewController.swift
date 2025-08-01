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

class WordsLangViewController: WordsBaseViewController, NSMenuItemValidation {

    var vm: WordsLangViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    var arrWords: [MLangWord] { vm.arrWords }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = WordsLangViewModel()
        refreshTableView(self)
        vm.$arrWords.didSet.sink { [unowned self] _ in
            doRefresh()
        } ~ subscriptions
        super.settingsChanged()
    }

    //MARK: tableView

    override func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvWords ? arrWords.count : vmPhrasesLang.arrPhrasesAll.count
    }

    override func endEditing(row: Int) {
        Task {
            let item = arrWords[row]
            await WordsLangViewModel.update(item: item)
            tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<tvWords.tableColumns.count))
        }
    }

    override func addNewWord() {
        guard !vm.newWord.isEmpty else {return}
        let item = vm.newLangWord()
        item.WORD = vmSettings.autoCorrectInput(text: vm.newWord)
        Task {
            await WordsLangViewModel.create(item: item)
            vm.arrWordsAll.append(item)
            tvWords.reloadData()
            tfNewWord.stringValue = ""
            vm.newWord = ""
        }
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vmEdit = WordsLangDetailViewModel(vm: vm, item: vm.newLangWord())
        detailVC.complete = { [unowned self] in tvWords.reloadData(); addWord(self) }
        presentAsSheet(detailVC)
    }

    override func deleteWord(row: Int) {
        Task {
            let item = arrWords[row]
            await WordsLangViewModel.delete(item: item)
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
        let detailVC = storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        let i = tvWords.selectedRow
        detailVC.vmEdit = WordsLangDetailViewModel(vm: vm, item: arrWords[i])
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

