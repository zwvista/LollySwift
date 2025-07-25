//
//  PhrasesBaseViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding
import AVFAudio

class PhrasesBaseViewController: WordsPhrasesBaseViewController {

    var vmWordsLang: WordsLangViewModel!
    override var vmWords: WordsBaseViewModel { vmWordsLang }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        _ = vmPhrases.textFilter_ <~> sfTextFilter.rx.text.orEmpty
        _ = vmPhrases.scopeFilter_ <~> scScopeFilter.rx.selectedLabel
        sfTextFilter.rx.searchFieldDidStartSearching.subscribe { [unowned self] _ in
            vmPhrases.textFilter = vmSettings.autoCorrectInput(text: vmPhrases.textFilter)
        } ~ rx.disposeBag
        super.settingsChanged()
        vmWordsLang = WordsLangViewModel(settings: vmSettings)
    }

    func doRefresh() {
        tvPhrases.reloadData()
        updateStatusText()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvPhrases {
            let item = phraseItemForRow(row: row)!
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = vmWordsLang.arrWordsAll[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvPhrases {
            selectedPhraseChanged()
            getWords()
        } else {
            selectedWordChanged()
            searchDict(self)
            responder = tvPhrases
        }
        speak()
    }

    func endEditing(row: Int) {
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tvPhrases.row(for: sender)
        guard row != -1 else {return}
        let col = tvPhrases.column(for: sender)
        let key = tvPhrases.tableColumns[col].identifier.rawValue
        let item = phraseItemForRow(row: row)!
        let oldValue = String(describing: item.value(forKey: key) ?? "")
        var newValue = sender.stringValue
        if key == "PHRASE" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        endEditing(row: row)
    }

    @IBAction func deletePhrase(_ sender: AnyObject) {
        let row = tvPhrases.selectedRow
        guard row != -1 else {return}
        let alert = NSAlert()
        alert.messageText = "Delete Phrase"
        alert.informativeText = "Are you sure?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        guard alert.runModal() == .alertFirstButtonReturn else {return}
        deletePhrase(row: row)
    }

    func deletePhrase(row: Int) {
    }

    override func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        vmWordsLang.arrWordsAll[row]
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases"
    }

    override func speak() {
        guard isSpeaking else {return}
        let responder = view.window?.firstResponder
        let dialogue = AVSpeechUtterance(string: responder == tvWords ? vmWords.selectedWord : vmPhrases.selectedPhrase)
        dialogue.voice = AVSpeechSynthesisVoice(identifier: vmSettings.macVoiceName)
        synth.speak(dialogue)
    }

    func getWords() {
        vmWordsLang.getWords(phraseid: vmPhrases.selectedPhraseID).subscribe { [unowned self] _ in
            tvWords.reloadData()
            if tvWords.numberOfRows > 0 {
                tvWords.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            }
        } ~ rx.disposeBag
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let detailVC = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        let i = tvWords.selectedRow
        detailVC.vmEdit = WordsLangDetailViewModel(vm: vmWordsLang, item: vmWordsLang.arrWordsAll[i])
        detailVC.complete = { [unowned self] in
            tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvWords.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func dissociateWord(_ sender: AnyObject) {
        guard vmWords.selectedWordID != 0 else {return}
        MWordPhrase.dissociate(wordid: vmWords.selectedWordID, phraseid: vmPhrases.selectedPhraseID).subscribe { [unowned self] _ in
            tvWords.reloadData()
        } ~ rx.disposeBag
    }
}

