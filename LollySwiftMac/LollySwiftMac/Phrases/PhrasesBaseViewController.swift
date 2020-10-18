//
//  PhrasesBaseViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class PhrasesBaseViewController: WordsPhrasesBaseViewController {
    
    func doRefresh() {
        tvPhrases.reloadData()
        updateStatusText()
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        textFilter = vmSettings.autoCorrectInput(text: textFilter)
        sfFilter.stringValue = textFilter
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        scTextFilter.performClick(self)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatusText()
        let row = tvPhrases.selectedRow
        selectedPhrase = row == -1 ? "" : phraseItemForRow(row: row)!.PHRASE
        if isSpeaking {
            speak(self)
        }
    }
    
    func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        nil
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = phraseItemForRow(row: row)!
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

    func endEditing(row: Int) {
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

    @IBAction func copyPhrase(_ sender: AnyObject) {
        MacApi.copyText(selectedPhrase)
    }
    
    @IBAction func googlePhrase(_ sender: AnyObject) {
        MacApi.googleString(selectedPhrase)
    }

//    @IBAction func speak(_ sender: AnyObject) {
//        synth.startSpeaking(selectedPhrase)
//    }
    
    func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases"
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PhrasesBaseWindowController: WordsPhrasesBaseWindowController {

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

