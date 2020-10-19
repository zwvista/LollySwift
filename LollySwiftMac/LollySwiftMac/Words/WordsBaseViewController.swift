//
//  WordsBaseViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/01/05.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class WordsPhrasesBaseViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate, LollyProtocol {
    
    @IBOutlet weak var tfNewWord: NSTextField!
    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var sfFilter: NSSearchField!
    @IBOutlet weak var tvWords: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!
    @IBOutlet weak var tvPhrases: NSTableView!
    @IBOutlet weak var tabView: NSTabView!
    
    var vmSettings: SettingsViewModel! { nil }
    
    var selectedDictReferenceIndex = 0
    @objc var newWord = ""
    @objc var textFilter = ""
    var selectedWord = ""
    var selectedWordID = 0
    var selectedPhrase = ""
    var selectedPhraseID = 0
    let synth = NSSpeechSynthesizer()
    var isSpeaking = true
    weak var responder: NSView? = nil
//    var textFilter = BehaviorRelay(value: "")
//    var scopeFilter = BehaviorRelay(value: SettingsViewModel.arrScopeWordFilters[0])
//    var textbookFilter = BehaviorRelay(value: 0)

    let imageOff = NSImage(named: "NSStatusNone")
    let imageOn = NSImage(named: "NSStatusAvailable")

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
//        _ = vm.textFilter <~> sfFilter.rx.text.orEmpty
//        _ = vm.scopeFilter <~> scTextFilter.rx.selectedLabel
    }
    
    // Hold a reference to the window controller in order to prevent it from being released
    // Without it, we would not be able to access its child controls afterwards
    var wc: WordsPhrasesBaseWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
        wc = view.window!.windowController as? WordsPhrasesBaseWindowController
        wc.scSpeak.selectedSegment = isSpeaking ? 1 : 0
        // For some unknown reason, the placeholder string of the filter text field
        // cannot be set in the storyboard
        // https://stackoverflow.com/questions/5519512/nstextfield-placeholder-text-doesnt-show-unless-editing
        sfFilter?.placeholderString = "Filter"
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        wc = nil
    }

    func settingsChanged() {
        selectedDictReferenceIndex = vmSettings.selectedDictReferenceIndex
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
    }
    
    func speak() {
        guard isSpeaking else {return}
        let responder = view.window!.firstResponder
        if responder == tvPhrases {
            synth.startSpeaking(selectedPhrase)
        } else if responder == tvWords {
            synth.startSpeaking(selectedWord)
        }
    }
    
    @IBAction func speak(_ sender: AnyObject) {
        speak()
    }
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! NSSegmentedControl).selectedSegment == 1
        speak()
    }
    
    func removeAllTabs() {
        while !tabView.tabViewItems.isEmpty {
            tabView.removeTabViewItem(tabView.tabViewItems[0])
        }
    }
    
    func selectedWordChanged() {
        let row = tvWords.selectedRow
        if row == -1 {
            selectedWord = ""
            selectedWordID = 0
        } else {
            let item = wordItemForRow(row: row)!
            selectedWord = item.WORD
            selectedWordID = item.WORDID
        }
    }
    
    func selectedPhraseChanged() {
        let row = tvPhrases.selectedRow
        if row == -1 {
            selectedPhrase = ""
            selectedPhraseID = 0
        } else {
            let item = phraseItemForRow(row: row)!
            selectedPhrase = item.PHRASE
            selectedPhraseID = item.PHRASEID
        }
    }

    @IBAction func searchDict(_ sender: AnyObject) {
        if sender is NSToolbarItem {
            let tbi = sender as! NSToolbarItem
            selectedDictReferenceIndex = tbi.tag
            let item = vmSettings.arrDictsReference[selectedDictReferenceIndex]
            let name = item.DICTNAME
            let item2 = vmSettings.arrDictsReference.first { $0.DICTNAME == name }!
            if let tvi = tabView.tabViewItems.first(where: { $0.label == name }) {
                tbi.image = imageOff
                tabView.removeTabViewItem(tvi)
            } else {
                tbi.image = imageOn
                let vc = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsDictViewController") as! WordsDictViewController
                vc.vcWords = self
                vc.dict = item2
                let tvi = NSTabViewItem(viewController: vc)
                tvi.label = name
                tabView.addTabViewItem(tvi)
            }
        }
        if responder == nil {
            responder = tvWords
        }
        let word = selectedWord.isEmpty ? newWord : selectedWord
        for item in tabView.tabViewItems {
            (item.viewController as! WordsDictViewController).searchWord(word: word)
        }
    }

    func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        nil
    }

    func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        nil
    }

    func needRegainFocus() -> Bool {
        true
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsBaseViewController: WordsPhrasesBaseViewController {
    
    var arrPhrases: [MLangPhrase]! { nil }

    func doRefresh() {
        tvWords.reloadData()
        updateStatusText()
    }
    
    @IBAction func addNewWord(_ sender: Any) {
        if !newWord.isEmpty {
            addNewWord()
        }
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        textFilter = vmSettings.autoCorrectInput(text: textFilter)
        sfFilter.stringValue = textFilter
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        scTextFilter.performClick(self)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvWords {
            let item = wordItemForRow(row: row)!
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = arrPhrases[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvWords {
            selectedWordChanged()
            updateStatusText()
            searchDict(self)
            searchPhrases()
        } else {
            selectedPhraseChanged()
        }
        speak()
    }
    
    func endEditing(row: Int) {
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tvWords.row(for: sender)
        guard row != -1 else {return}
        let col = tvWords.column(for: sender)
        let key = tvWords.tableColumns[col].identifier.rawValue
        let item = wordItemForRow(row: row)!
        let oldValue = String(describing: item.value(forKey: key) ?? "")
        var newValue = sender.stringValue
        if key == "WORD" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        endEditing(row: row)
    }

    func addNewWord() {
    }
    
    func confirmDelete() -> Bool {
        true
    }

    @IBAction func deleteWord(_ sender: AnyObject) {
        let row = tvWords.selectedRow
        guard row != -1 else {return}
        let alert = NSAlert()
        alert.messageText = "Delete Word"
        alert.informativeText = "Are you sure?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        guard !confirmDelete() || alert.runModal() == .alertFirstButtonReturn else {return}
        deleteWord(row: row)
    }
    
    func deleteWord(row: Int) {
    }
    
    func searchPhrases() {
    }
    
    override func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }

    @IBAction func copyWord(_ sender: AnyObject) {
        MacApi.copyText(selectedWord)
    }
    
    @IBAction func googleWord(_ sender: AnyObject) {
        MacApi.googleString(selectedWord)
    }

    @IBAction func openOnlineDict(_ sender: AnyObject) {
        let row = tvWords.selectedRow
        guard row != -1 else {return}
        let word = wordItemForRow(row: row)!.WORD
        for item in tabView.tabViewItems {
            let vc = item.viewController as! WordsDictViewController
            let url = vc.dict.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
            MacApi.openURL(url)
        }
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words"
    }
}

class WordsPhrasesBaseWindowController: NSWindowController, LollyProtocol, NSWindowDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var scSpeak: NSSegmentedControl!
    // Outlet collections have been implemented for iOS, but not in Cocoa
    // https://stackoverflow.com/questions/24805180/swift-put-multiple-iboutlets-in-an-array
    // @IBOutlet var tbiDicts: [NSToolbarItem]!
    @IBOutlet weak var tbiDict0: NSToolbarItem!
    @IBOutlet weak var tbiDict1: NSToolbarItem!
    @IBOutlet weak var tbiDict2: NSToolbarItem!
    @IBOutlet weak var tbiDict3: NSToolbarItem!
    @IBOutlet weak var tbiDict4: NSToolbarItem!
    @IBOutlet weak var tbiDict5: NSToolbarItem!
    @IBOutlet weak var tbiDict6: NSToolbarItem!
    @IBOutlet weak var tbiDict7: NSToolbarItem!
    @IBOutlet weak var tbiDict8: NSToolbarItem!
    @IBOutlet weak var tbiDict9: NSToolbarItem!
    @IBOutlet weak var tbiDict10: NSToolbarItem!
    @IBOutlet weak var tbiDict11: NSToolbarItem!
    @IBOutlet weak var tbiDict12: NSToolbarItem!
    @IBOutlet weak var tbiDict13: NSToolbarItem!
    @IBOutlet weak var tbiDict14: NSToolbarItem!
    @IBOutlet weak var tbiDict15: NSToolbarItem!
    @IBOutlet weak var tbiDict16: NSToolbarItem!
    @IBOutlet weak var tbiDict17: NSToolbarItem!
    @IBOutlet weak var tbiDict18: NSToolbarItem!
    @IBOutlet weak var tbiDict19: NSToolbarItem!
    @IBOutlet weak var tbiDict20: NSToolbarItem!
    @IBOutlet weak var tbiDict21: NSToolbarItem!
    @IBOutlet weak var tbiDict22: NSToolbarItem!
    @IBOutlet weak var tbiDict23: NSToolbarItem!
    @IBOutlet weak var tbiDict24: NSToolbarItem!
    @IBOutlet weak var tbiDict25: NSToolbarItem!
    @IBOutlet weak var tbiDict26: NSToolbarItem!
    @IBOutlet weak var tbiDict27: NSToolbarItem!
    @IBOutlet weak var tbiDict28: NSToolbarItem!
    @IBOutlet weak var tbiDict29: NSToolbarItem!
    @IBOutlet weak var tbiDict30: NSToolbarItem!
    @IBOutlet weak var tbiDict31: NSToolbarItem!
    @IBOutlet weak var tbiDict32: NSToolbarItem!
    @IBOutlet weak var tbiDict33: NSToolbarItem!
    @IBOutlet weak var tbiDict34: NSToolbarItem!
    @IBOutlet weak var tbiDict35: NSToolbarItem!
    @IBOutlet weak var tbiDict36: NSToolbarItem!
    @IBOutlet weak var tbiDict37: NSToolbarItem!
    @IBOutlet weak var tbiDict38: NSToolbarItem!
    @IBOutlet weak var tbiDict39: NSToolbarItem!
    var vc: WordsPhrasesBaseViewController { contentViewController as! WordsPhrasesBaseViewController }
    @objc var vm: SettingsViewModel! { vc.vmSettings }
    private var defaultToolbarItemCount = 0
    
    var identifiers: [NSToolbarItem.Identifier]!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.defaultToolbarItemCount = self.toolbar.items.count - 40
            self.settingsChanged()
        }
    }
    
    func settingsChanged() {
        vc.tvWords.selectRowIndexes(IndexSet(), byExtendingSelection: false)
        vc.removeAllTabs()
        for i in 0..<40 {
            let item = toolbar.items[defaultToolbarItemCount + i]
            if i < vm.arrDictsReference.count {
                item.label = vm.arrDictsReference[i].DICTNAME
                item.tag = i
                item.target = contentViewController
                item.action = #selector(WordsBaseViewController.searchDict(_:))
                item.image = vc.imageOff
                item.isEnabled = true
            } else {
                item.label = ""
                item.tag = -1
                item.image = nil
                item.target = nil
                item.action = nil
                item.isEnabled = false
            }
        }
        for o in vm.selectedDictsReference {
            let item = toolbar.items.first { $0.label == o.DICTNAME }!
            vc.searchDict(item)
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsBaseWindowController: WordsPhrasesBaseWindowController {
}
