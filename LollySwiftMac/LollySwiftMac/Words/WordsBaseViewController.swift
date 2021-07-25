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

class WordsPhrasesBaseViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, LollyProtocol {
    
    @IBOutlet weak var tfNewWord: NSTextField!
    @IBOutlet weak var scScopeFilter: NSSegmentedControl!
    @IBOutlet weak var sfTextFilter: NSSearchField!
    @IBOutlet weak var tvWords: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!
    @IBOutlet weak var tvPhrases: NSTableView!
    @IBOutlet weak var tabView: NSTabView!
    
    var vmSettings: SettingsViewModel! { nil }
    var vmWords: WordsBaseViewModel! { nil }
    var vmPhrases: PhrasesBaseViewModel! { nil }
    var initSettingsInViewDidLoad: Bool { true }

    let synth = NSSpeechSynthesizer()
    var isSpeaking = true
    weak var responder: NSView? = nil

    let imageOff = NSImage(named: "NSStatusNone")
    let imageOn = NSImage(named: "NSStatusAvailable")

    override func viewDidLoad() {
        super.viewDidLoad()
        if (initSettingsInViewDidLoad) {
            settingsChanged()
        }
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
        sfTextFilter?.placeholderString = "Filter"
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        wc = nil
    }

    func settingsChanged() {
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
    }
    
    func speak() {
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
            vmWords.selectedWord = ""
            vmWords.selectedWordID = 0
        } else {
            let item = wordItemForRow(row: row)!
            vmWords.selectedWord = item.WORD
            vmWords.selectedWordID = item.WORDID
        }
    }
    
    func selectedPhraseChanged() {
        let row = tvPhrases.selectedRow
        if row == -1 {
            vmPhrases.selectedPhrase = ""
            vmPhrases.selectedPhraseID = 0
        } else {
            let item = phraseItemForRow(row: row)!
            vmPhrases.selectedPhrase = item.PHRASE
            vmPhrases.selectedPhraseID = item.PHRASEID
        }
    }

    @IBAction func searchDict(_ sender: AnyObject) {
        if sender is NSToolbarItem {
            let tbi = sender as! NSToolbarItem
            let item = vmSettings.arrDictsReference[tbi.tag]
            let name = item.DICTNAME
            if let tvi = tabView.tabViewItems.first(where: { $0.label == name }) {
                tbi.image = imageOff
                tabView.removeTabViewItem(tvi)
            } else {
                tbi.image = imageOn
                let vc = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsDictViewController") as! WordsDictViewController
                vc.vcWords = self
                vc.dict = item
                let tvi = NSTabViewItem(viewController: vc)
                tvi.label = name
                tabView.addTabViewItem(tvi)
            }
        }
        if responder == nil {
            responder = tvWords
        }
        let word = vmWords.selectedWord.isEmpty ? vmWords.newWord.value : vmWords.selectedWord
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
    
    func applyFilters() {
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsBaseViewController: WordsPhrasesBaseViewController {
    
    var vmPhrasesLang: PhrasesLangViewModel!
    override var vmPhrases: PhrasesBaseViewModel { vmPhrasesLang }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tfNewWord = tfNewWord {
            _ = vmWords.newWord <~> tfNewWord.rx.text.orEmpty
            tfNewWord.rx.controlTextDidEndEditing.subscribe(onNext: { [unowned self] _ in
                if !self.vmWords.newWord.value.isEmpty {
                    self.addNewWord()
                }
            }) ~ rx.disposeBag
        }
        if let sfTextFilter = sfTextFilter {
            _ = vmWords.textFilter <~> sfTextFilter.rx.text.orEmpty
            _ = vmWords.scopeFilter <~> scScopeFilter.rx.selectedLabel
            sfTextFilter.rx.searchFieldDidStartSearching.subscribe { [unowned self] _ in
                self.vmWords.textFilter.accept(self.vmSettings.autoCorrectInput(text: self.vmWords.textFilter.value))
            } ~ rx.disposeBag
            sfTextFilter.rx.searchFieldDidEndSearching.subscribe { [unowned self] _ in
                self.applyFilters()
            } ~ rx.disposeBag
            sfTextFilter.rx.text.subscribe(onNext: { [unowned self] _ in
                self.applyFilters()
            }) ~ rx.disposeBag
            scScopeFilter.rx.selectedLabel.subscribe(onNext: { [unowned self] _ in
                self.applyFilters()
            }) ~ rx.disposeBag
        }
    }

    override func settingsChanged() {
        super.settingsChanged()
        vmPhrasesLang = PhrasesLangViewModel(settings: vmSettings)
    }

    func doRefresh() {
        tvWords.reloadData()
        updateStatusText()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvWords {
            let item = wordItemForRow(row: row)!
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = vmPhrasesLang.arrPhrases[row]
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
            getPhrases()
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
    
    override func phraseItemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        vmPhrasesLang.arrPhrases[row]
    }

    @IBAction func copyWord(_ sender: AnyObject) {
        MacApi.copyText(vmWords.selectedWord)
    }
    
    @IBAction func googleWord(_ sender: AnyObject) {
        MacApi.googleString(vmWords.selectedWord)
    }

    @IBAction func openOnlineDict(_ sender: AnyObject) {
        let row = tvWords.selectedRow
        guard row != -1 else {return}
        for item in tabView.tabViewItems {
            let vc = item.viewController as! WordsDictViewController
            MacApi.openURL(vc.url)
        }
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words"
    }
    
    override func speak() {
        guard isSpeaking else {return}
        let responder = view.window!.firstResponder
        if responder == tvPhrases {
            synth.startSpeaking(vmPhrases.selectedPhrase)
        } else {
            synth.startSpeaking(vmWords.selectedWord)
        }
    }
    
    func getPhrases() {
        vmPhrasesLang.getPhrases(wordid: vmWords.selectedWordID).subscribe(onCompleted: {
            self.tvPhrases.reloadData()
        }) ~ rx.disposeBag
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let editVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        editVC.vm = vmPhrasesLang
        let i = tvPhrases.selectedRow
        editVC.item = vmPhrasesLang.arrPhrases[i]
        editVC.complete = {
            self.tvPhrases.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvPhrases.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
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
        vc.tvWords?.selectRowIndexes(IndexSet(), byExtendingSelection: false)
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
