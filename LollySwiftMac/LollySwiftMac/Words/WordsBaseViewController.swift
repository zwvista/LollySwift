//
//  WordsBaseViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/01/05.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import Combine
import AVFAudio

class WordsPhrasesBaseViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, LollyProtocol {

    @IBOutlet weak var scSpeak: NSSegmentedControl!
    @IBOutlet weak var tfNewWord: NSTextField!
    @IBOutlet weak var scScopeFilter: NSSegmentedControl!
    @IBOutlet weak var sfTextFilter: NSSearchField!
    @IBOutlet weak var tvWords: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!
    @IBOutlet weak var tvPhrases: NSTableView!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet var menuWords: NSMenu!
    @IBOutlet var menuPhrases: NSMenu!

    var vmWords: WordsBaseViewModel! { nil }
    var vmPhrases: PhrasesBaseViewModel! { nil }
    var initSettingsInViewDidLoad: Bool { true }

    let synth = AVSpeechSynthesizer()
    var isSpeaking = true
    weak var responder: NSView? = nil

    let imageOff = NSImage(named: "NSStatusNone")
    let imageOn = NSImage(named: "NSStatusAvailable")
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        if (initSettingsInViewDidLoad) {
            settingsChanged()
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        scSpeak.selectedSegment = isSpeaking ? 1 : 0
        // For some unknown reason, the placeholder string of the filter text field
        // cannot be set in the storyboard
        // https://stackoverflow.com/questions/5519512/nstextfield-placeholder-text-doesnt-show-unless-editing
        sfTextFilter?.placeholderString = "Filter"
    }

    func settingsChanged() {
        tvWords?.selectRowIndexes(IndexSet(), byExtendingSelection: false)
        removeAllTabs()
        for item in vmSettings.selectedDictsReference {
            let vc = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsDictViewController") as! WordsDictViewController
            vc.vcWords = self
            vc.dict = item
            let tvi = NSTabViewItem(viewController: vc)
            tvi.label = item.DICTNAME
            tabView.addTabViewItem(tvi)
        }
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
        let word = vmWords.selectedWord.isEmpty ? vmWords.newWord : vmWords.selectedWord
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

    @IBAction func copyWord(_ sender: AnyObject) {
        MacApi.copyText(vmWords.selectedWord)
    }

    @IBAction func googleWord(_ sender: AnyObject) {
        MacApi.googleString(vmWords.selectedWord)
    }

    @IBAction func copyPhrase(_ sender: AnyObject) {
        MacApi.copyText(vmPhrases.selectedPhrase)
    }

    @IBAction func googlePhrase(_ sender: AnyObject) {
        MacApi.googleString(vmPhrases.selectedPhrase)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class WordsBaseViewController: WordsPhrasesBaseViewController {

    var vmPhrasesLang: PhrasesLangViewModel!
    override var vmPhrases: PhrasesBaseViewModel { vmPhrasesLang }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        if let tfNewWord = tfNewWord {
            vmWords.$newWord <~> tfNewWord.textProperty ~ subscriptions
            tfNewWord.controlTextDidEndEditingPublisher.sink { [unowned self] in
                commitEditing()
                if !vmWords.newWord.isEmpty {
                    addNewWord()
                }
            } ~ subscriptions
        }
        if let sfTextFilter = sfTextFilter {
            vmWords.$textFilter <~> sfTextFilter.textProperty ~ subscriptions
            vmWords.$scopeFilter <~> scScopeFilter.selectedLabelProperty ~ subscriptions
            sfTextFilter.searchFieldDidStartSearchingPublisher.sink { [unowned self] in
                vmWords.textFilter = vmSettings.autoCorrectInput(text: vmWords.textFilter)
            } ~ subscriptions
        }
        super.settingsChanged()
        vmPhrasesLang = PhrasesLangViewModel()
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
            let item = vmPhrasesLang.arrPhrasesAll[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvWords {
            selectedWordChanged()
            searchDict(self)
            Task {
                await getPhrases()
            }
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
        vmPhrasesLang.arrPhrasesAll[row]
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
        let responder = view.window?.firstResponder
        let dialogue = AVSpeechUtterance(string: responder == tvPhrases ? vmPhrases.selectedPhrase : vmWords.selectedWord)
        dialogue.voice = AVSpeechSynthesisVoice(identifier: vmSettings.macVoiceName)
        synth.speak(dialogue)
    }

    func getPhrases() async {
        await vmPhrasesLang.getPhrases(wordid: vmWords.selectedWordID)
        tvPhrases.reloadData()
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let detailVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        let i = tvPhrases.selectedRow
        detailVC.vmEdit = PhrasesLangDetailViewModel(vm: vmPhrasesLang, item: vmPhrasesLang.arrPhrasesAll[i])
        detailVC.complete = { [unowned self] in
            tvPhrases.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvPhrases.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func dissociatePhrase(_ sender: AnyObject) {
        guard vmPhrases.selectedPhraseID != 0 else {return}
        Task {
            await MWordPhrase.dissociate(wordid: vmWords.selectedWordID, phraseid: vmPhrases.selectedPhraseID)
            tvPhrases.reloadData()
        }
    }
}
