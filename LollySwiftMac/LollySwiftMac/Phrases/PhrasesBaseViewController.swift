//
//  PhrasesBaseViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import Combine
import AVFAudio

class PhrasesBaseViewController: WordsPhrasesBaseViewController {

    var vmWordsLang: WordsLangViewModel!
    override var vmWords: WordsBaseViewModel { vmWordsLang }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vmPhrases.$textFilter <~> sfTextFilter.textProperty ~ subscriptions
        vmPhrases.$scopeFilter <~> scScopeFilter.selectedLabelProperty ~ subscriptions
        sfTextFilter.searchFieldDidStartSearchingPublisher.sink { [unowned self] in
            vmPhrases.textFilter = vmSettings.autoCorrectInput(text: vmPhrases.textFilter)
        } ~ subscriptions
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
            let item = vmWordsLang.arrWords[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvPhrases {
            selectedPhraseChanged()
            Task {
                await getWords()
            }
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
        vmWordsLang.arrWords[row]
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases"
    }

    override func speak() {
        guard isSpeaking else {return}
        let responder = view.window!.firstResponder
        let dialogue = AVSpeechUtterance(string: responder == tvWords ? vmWords.selectedWord : vmPhrases.selectedPhrase)
        dialogue.voice = AVSpeechSynthesisVoice(identifier: vmSettings.macVoiceName)
        synth.speak(dialogue)
    }

    func getWords() async {
        await vmWordsLang.getWords(phraseid: vmPhrases.selectedPhraseID)
        tvWords.reloadData()
        if tvWords.numberOfRows > 0 {
            tvWords.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let detailVC = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        let i = tvWords.selectedRow
        detailVC.vmEdit = WordsLangDetailViewModel(vm: vmWordsLang, item: vmWordsLang.arrWords[i])
        detailVC.complete = { [unowned self] in
            tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvWords.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func dissociateWord(_ sender: AnyObject) {
        guard vmWords.selectedWordID != 0 else {return}
        Task {
            await MWordPhrase.dissociate(wordid: vmWords.selectedWordID, phraseid: vmPhrases.selectedPhraseID)
            tvWords.reloadData()
        }
    }
}

class PhrasesBaseWindowController: WordsPhrasesBaseWindowController {
}

