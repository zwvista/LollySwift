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
    
    // Take a reference to the window controller in order to prevent it from being released
    // If the window controller were released, we would not be able to retrieve the text filter
    var wc: PhrasesBaseWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
        wc = view.window!.windowController as? PhrasesBaseWindowController
        // For some unknown reason, the placeholder string of the filter text field
        // cannot be set in the storyboard
        // https://stackoverflow.com/questions/5519512/nstextfield-placeholder-text-doesnt-show-unless-editing
        wc.tfFilter?.placeholderString = "Filter"
    }
    override func viewWillDisappear() {
        wc = nil
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
    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var tfFilter: NSTextField!
    @objc var textFilter = ""
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @objc var textbookFilter = 0

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func settingsChanged() {
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        guard searchfield === tfFilter else {return}
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        if scTextFilter.selectedSegment == 0 {
            scTextFilter.selectedSegment = 1
        }
        filterPhrase()
    }

    func filterPhrase() {
    }

    func windowWillClose(_ notification: Notification) {
        tfFilter?.unbindAll()
        pubTextbookFilter?.unbindAll()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

