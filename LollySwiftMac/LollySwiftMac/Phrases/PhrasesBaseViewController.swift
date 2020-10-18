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

class PhrasesBaseViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, LollyProtocol {
    
    var vmSettings: SettingsViewModel! { nil }
    @IBOutlet weak var tvPhrases: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!

    var selectedPhrase = ""
    let synth = NSSpeechSynthesizer()
    var isSpeaking = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }
    
    // Hold a reference to the window controller in order to prevent it from being released
    // Without it, we would not be able to access its child controls afterwards
    var wc: PhrasesBaseWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
        wc = view.window!.windowController as? PhrasesBaseWindowController
        wc.scSpeak.selectedSegment = isSpeaking ? 1 : 0
        // For some unknown reason, the placeholder string of the filter text field
        // cannot be set in the storyboard
        // https://stackoverflow.com/questions/5519512/nstextfield-placeholder-text-doesnt-show-unless-editing
        wc.sfFilter?.placeholderString = "Filter"
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        wc = nil
    }
    
    func doRefresh() {
        tvPhrases.reloadData()
        updateStatusText()
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatusText()
        let row = tvPhrases.selectedRow
        selectedPhrase = row == -1 ? "" : itemForRow(row: row)!.PHRASE
        if isSpeaking {
            speak(self)
        }
    }
    
    func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        nil
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
        let item = itemForRow(row: row)!
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

    @IBAction func speak(_ sender: AnyObject) {
        synth.startSpeaking(selectedPhrase)
    }
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! NSSegmentedControl).selectedSegment == 1
        if isSpeaking {
            speak(self)
        }
    }

    func settingsChanged() {
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
    }
    
    func updateStatusText() {
        tfStatusText.stringValue = "\(tvPhrases.numberOfRows) Phrases"
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PhrasesBaseWindowController: NSWindowController, NSSearchFieldDelegate, NSWindowDelegate, LollyProtocol {
    @IBOutlet weak var scSpeak: NSSegmentedControl!
    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var sfFilter: NSSearchField!
    @objc var textFilter = ""
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @objc var textbookFilter = 0
    var vc: PhrasesBaseViewController { contentViewController as! PhrasesBaseViewController }
    @objc var vm: SettingsViewModel! { vc.vmSettings }

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func settingsChanged() {
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        textFilter = vm.autoCorrectInput(text: textFilter)
        sfFilter.stringValue = textFilter
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        scTextFilter.performClick(self)
    }

    func windowWillClose(_ notification: Notification) {
        sfFilter?.unbindAll()
        pubTextbookFilter?.unbindAll()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

