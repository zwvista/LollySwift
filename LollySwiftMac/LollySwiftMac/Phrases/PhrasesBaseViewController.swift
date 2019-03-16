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

class PhrasesBaseViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!

    let disposeBag = DisposeBag()
    var selectedPhrase = ""
    let synth = NSSpeechSynthesizer()
    var speakOrNot = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedPhraseChanged()
        if speakOrNot {
            speak(self)
        }
    }
    
    func selectedPhraseChanged() {
    }
    
    func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        return nil;
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = itemForRow(row: row)!
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell;
    }

    func endEditing(row: Int) {
    }
    
    @IBAction func deletePhrase(_ sender: Any) {
        let row = tableView.selectedRow
        guard row != -1 else {return}
        deletePhrase(row: row)
    }
    
    func deletePhrase(row: Int) {
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        guard row != -1 else {return}
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].title
        let item = itemForRow(row: row)!
        let oldValue = String(describing: item.value(forKey: key)!)
        var newValue = sender.stringValue
        if key == "PHRASE" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        endEditing(row: row)
    }

    @IBAction func copyPhrase(_ sender: Any) {
        MacApi.copyText(selectedPhrase)
    }
    
    @IBAction func googlePhrase(_ sender: Any) {
        MacApi.googleString(selectedPhrase)
    }

    @IBAction func speak(_ sender: Any) {
        synth.startSpeaking(selectedPhrase)
    }
    
    @IBAction func speakOrNotChanged(_ sender: Any) {
        speakOrNot = (sender as! NSSegmentedControl).selectedSegment == 1
        if speakOrNot {
            speak(self)
        }
    }

    func settingsChanged() {
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PhrasesBaseWindowController: NSWindowController, NSTextFieldDelegate, NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

