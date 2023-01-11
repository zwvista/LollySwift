//
//  PhrasesBaseViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import Combine

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
            self.vmPhrases.textFilter = self.vmSettings.autoCorrectInput(text: self.vmPhrases.textFilter)
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
            updateStatusText()
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

    @IBAction func copyPhrase(_ sender: AnyObject) {
        MacApi.copyText(vmPhrases.selectedPhrase)
    }

    @IBAction func googlePhrase(_ sender: AnyObject) {
        MacApi.googleString(vmPhrases.selectedPhrase)
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases"
    }

    override func speak() {
        guard isSpeaking else {return}
        let responder = view.window!.firstResponder
        if responder == tvWords {
            synth.startSpeaking(vmWords.selectedWord)
        } else {
            synth.startSpeaking(vmPhrases.selectedPhrase)
        }
    }

    func getWords() async {
        await vmWordsLang.getWords(phraseid: vmPhrases.selectedPhraseID)
        tvWords.reloadData()
        if tvWords.numberOfRows > 0 {
            tvWords.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let editVC = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        let i = tvWords.selectedRow
        editVC.vmEdit = WordsLangDetailViewModel(vm: vmWordsLang, item: vmWordsLang.arrWords[i])
        editVC.complete = {
            self.tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
    }
}

class PhrasesBaseWindowController: WordsPhrasesBaseWindowController {
}

