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
import RxBinding

class WordsLangViewController: WordsBaseViewController, NSMenuItemValidation {

    var vm: WordsLangViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrWords: [MLangWord] { vm.arrWordsFiltered }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = WordsLangViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {}
        vm.arrWordsFiltered_.subscribe { [unowned self] _ in
            doRefresh()
        } ~ rx.disposeBag
        super.settingsChanged()
    }

    //MARK: tableView

    override func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvWords ? arrWords.count : vmPhrasesLang.arrPhrases.count
    }

    override func endEditing(row: Int) {
        let item = arrWords[row]
        WordsLangViewModel.update(item: item).subscribe { [unowned self] _ in
            tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<tvWords.tableColumns.count))
        } ~ rx.disposeBag
    }

    override func addNewWord() {
        guard !vm.newWord.isEmpty else {return}
        let item = vm.newLangWord()
        item.WORD = vm.vmSettings.autoCorrectInput(text: vm.newWord)
        WordsLangViewModel.create(item: item).subscribe { [unowned self] _ in
            vm.arrWords.append(item)
            tvWords.reloadData()
            vm.newWord = ""
        } ~ rx.disposeBag
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vmEdit = WordsLangDetailViewModel(vm: vm, item: vm.newLangWord())
        detailVC.complete = { [unowned self] in tvWords.reloadData(); addWord(self) }
        presentAsSheet(detailVC)
    }

    override func deleteWord(row: Int) {
        let item = arrWords[row]
        WordsLangViewModel.delete(item: item).subscribe { [unowned self] _ in
            doRefresh()
        } ~ rx.disposeBag
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe { [unowned self] _ in
            doRefresh()
        } ~ rx.disposeBag
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
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.getNote(index: tvWords.selectedRow).subscribe { [unowned self] _ in
            tvWords.reloadData(forRowIndexes: [tvWords.selectedRow], columnIndexes: [col])
        } ~ rx.disposeBag
    }

    @IBAction func clearNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.clearNote(index: tvWords.selectedRow).subscribe { [unowned self] _ in
            tvWords.reloadData(forRowIndexes: [tvWords.selectedRow], columnIndexes: [col])
        } ~ rx.disposeBag
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
            getPhrases()
        }
        presentAsModalWindow(detailVC)
    }
}

class WordsLangWindowController: WordsBaseWindowController {
}

