//
//  PhrasesBaseViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class PhrasesBaseViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    var vmSettings: SettingsViewModel! {
        return nil
    }
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!

    let disposeBag = DisposeBag()
    var selectedPhrase = ""
    let synth = NSSpeechSynthesizer()
    var speakOrNot = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatusText()
        let row = tableView.selectedRow
        selectedPhrase = row == -1 ? "" : itemForRow(row: row)!.PHRASE
        if speakOrNot {
            speak(self)
        }
    }
    
    func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        return nil
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = itemForRow(row: row)!
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

    func endEditing(row: Int) {
    }
    
    @IBAction func deletePhrase(_ sender: AnyObject) {
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
        let key = tableView.tableColumns[col].identifier.rawValue
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

    @IBAction func copyPhrase(_ sender: AnyObject) {
        MacApi.copyText(selectedPhrase)
    }
    
    @IBAction func googlePhrase(_ sender: AnyObject) {
        MacApi.googleString(selectedPhrase)
    }

    @IBAction func speak(_ sender: AnyObject) {
        synth.startSpeaking(selectedPhrase)
    }
    
    @IBAction func speakOrNotChanged(_ sender: AnyObject) {
        speakOrNot = (sender as! NSSegmentedControl).selectedSegment == 1
        if speakOrNot {
            speak(self)
        }
    }

    func settingsChanged() {
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
    }
    
    func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Phrases"
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PhrasesBaseWindowController: NSWindowController, NSTextFieldDelegate, NSWindowDelegate, LollyProtocol {

    @objc var vm: SettingsViewModel! {
        return (contentViewController as! WordsBaseViewController).vmSettings
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func settingsChanged() {
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

