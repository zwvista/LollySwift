//
//  WordsBaseViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/01/05.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class WordsBaseViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, WKNavigationDelegate, LollyProtocol {
    var selectedDictItemIndex = 0
    
    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var scNewWord: NSSegmentedControl!
    @IBOutlet weak var sfNewWord: NSSearchField!
    @IBOutlet weak var scFilter: NSSegmentedControl!
    @IBOutlet weak var sfFilter: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!

    let disposeBag = DisposeBag()
    
    @objc var newWord = ""
    @objc var filterText = ""
    var selectedWord = ""
    var dictStatus = DictWebViewStatus.ready
    let synth = NSSpeechSynthesizer()
    var speakOrNot = false

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }
    
    // Prenvent the window controller from being released
    // The window controller's settingsChanged method needs to be called in SettingsViewController.close
    var wc: WordsBaseWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
        wc = view.window!.windowController as? WordsBaseWindowController
    }
    override func viewWillDisappear() {
        wc = nil
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        if searchfield === sfNewWord {
            scNewWordClick(self)
        } else if searchfield === sfFilter {
            if !filterText.isEmpty {
                scFilter.selectedSegment = 1
            }
            scFilter.performClick(self)
        }
    }
    
    @IBAction func scNewWordClick(_ sender: Any) {
        commitEditing()
        guard !newWord.isEmpty else {return}
        if scNewWord.selectedSegment == 0 {
            addNewWord()
        } else {
            searchWord(word: newWord)
        }
    }

    func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        return nil;
    }
    
    // https://stackoverflow.com/questions/10910779/coloring-rows-in-view-based-nstableview
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        let level = itemForRow(row: row)!.LEVEL
        if level != 0, let arr = vmSettings.USLEVELCOLORS![level] {
            rowView.backgroundColor = NSColor.hexColor(rgbValue: Int(arr[0], radix: 16)!)
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = itemForRow(row: row)!
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        let level = item.LEVEL
        if level != 0, let arr = vmSettings.USLEVELCOLORS![level] {
            cell.textField?.textColor = NSColor.hexColor(rgbValue: Int(arr[1], radix: 16)!)
        } else {
            cell.textField?.textColor = NSColor.windowFrameTextColor
        }
        return cell;
    }
    
    func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Words"
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatusText()
        searchDict(self)
        if speakOrNot {
            speak(self)
        }
    }
    
    func endEditing(row: Int) {
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        guard row != -1 else {return}
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].title
        let item = itemForRow(row: row)!
        let oldValue = String(describing: item.value(forKey: key))
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

    @IBAction func deleteWord(_ sender: Any) {
        let row = tableView.selectedRow
        guard row != -1 else {return}
        deleteWord(row: row)
    }
    
    func deleteWord(row: Int) {
    }

    func searchWord(word: String) {
        dictStatus = .ready
        let item = vmSettings.arrDictItems[selectedDictItemIndex]
        if item.DICTNAME.starts(with: "Custom") {
            let str = vmSettings.dictHtml(word: word, dictids: item.dictids())
            wvDict.loadHTMLString(str, baseURL: nil)
        } else {
            let item2 = vmSettings.arrDictsMean.first { $0.DICTNAME == item.DICTNAME }!
            let url = item2.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
            if item2.DICTTYPENAME == "OFFLINE" {
                wvDict.load(URLRequest(url: URL(string: "about:blank")!))
                RestApi.getHtml(url: url).subscribe(onNext: { html in
                    print(html)
                    let str = item2.htmlString(html, word: self.newWord)
                    self.wvDict.loadHTMLString(str, baseURL: nil)
                }).disposed(by: disposeBag)
            } else {
                wvDict.load(URLRequest(url: URL(string: url)!))
                if item2.DICTTYPENAME == "OFFLINE-ONLINE" {
                    dictStatus = .navigating
                }
            }
        }
    }
    
    @IBAction func searchDict(_ sender: Any) {
        if sender is NSToolbarItem {
            let tbItem = sender as! NSToolbarItem
            selectedDictItemIndex = tbItem.tag
            print(tbItem.toolbar!.selectedItemIdentifier!.rawValue)
        }
        let row = tableView.selectedRow
        if row == -1 {
            selectedWord = ""
            searchWord(word: newWord)
        } else {
            selectedWord = itemForRow(row: row)!.WORD
            searchWord(word: selectedWord)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.window?.makeKeyAndOrderFront(self)
        tableView.becomeFirstResponder()
        guard dictStatus == .navigating else {return}
        let item = vmSettings.arrDictItems[selectedDictItemIndex]
        let item2 = vmSettings.arrDictsMean.first { $0.DICTNAME == item.DICTNAME }!
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
            print(html)
            let str = item2.htmlString(html, word: self.selectedWord)
            self.wvDict.loadHTMLString(str, baseURL: nil)
            self.dictStatus = .ready
        }
    }

    func levelChanged(row: Int) -> Observable<Int> {
        return Observable.just(0)
    }
    
    private func changeLevel(by delta: Int) {
        let row = tableView.selectedRow
        guard row != -1 else {return}
        var item = itemForRow(row: row)!
        let newLevel = item.LEVEL + delta
        guard newLevel == 0 || vmSettings.USLEVELCOLORS[newLevel] != nil else {return}
        item.LEVEL = newLevel
        levelChanged(row: row).subscribe(onNext: {
            if $0 != 0 { self.tableView.reloadData() }
        }).disposed(by: disposeBag)
    }

    @IBAction func incLevel(_ sender: Any) {
        changeLevel(by: 1)
    }
    
    @IBAction func decLevel(_ sender: Any) {
        changeLevel(by: -1)
    }

    func settingsChanged() {
        selectedDictItemIndex = vmSettings.selectedDictItemIndex
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
    }
    
    @IBAction func copyWord(_ sender: Any) {
        MacApi.copyText(selectedWord)
    }
    
    @IBAction func googleWord(_ sender: Any) {
        MacApi.googleString(selectedWord)
    }
    
    @IBAction func speak(_ sender: Any) {
        synth.startSpeaking(selectedWord)
    }
    
    @IBAction func speakOrNotChanged(_ sender: Any) {
        speakOrNot = (sender as! NSSegmentedControl).selectedSegment == 1
        if speakOrNot {
            speak(self)
        }
    }

    @IBAction func openOnlineDict(_ sender: Any) {
        let item = vmSettings.arrDictItems[selectedDictItemIndex]
        if !item.DICTNAME.starts(with: "Custom") {
            let item2 = vmSettings.arrDictsMean.first { $0.DICTNAME == item.DICTNAME }!
            let url = item2.urlString(word: selectedWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
            MacApi.openPage(url)
        }
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsBaseWindowController: NSWindowController, LollyProtocol, NSWindowDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var toolbar: NSToolbar!
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
    @objc var vm: SettingsViewModel {return vmSettings}
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
        let img = toolbar.items[defaultToolbarItemCount].image
        for i in 0..<40 {
            if i < vmSettings.arrDictItems.count {
                let item = toolbar.items[defaultToolbarItemCount + i]
                item.label = vmSettings.arrDictItems[i].DICTNAME
                item.target = contentViewController
                item.action = #selector(WordsBaseViewController.searchDict(_:))
                item.isEnabled = true
                item.image = img
                if i == vmSettings.selectedDictItemIndex {
                    toolbar.selectedItemIdentifier = item.itemIdentifier
                }
            } else {
                let item = toolbar.items[defaultToolbarItemCount + i]
                item.label = ""
                item.target = nil
                item.action = nil
                item.image = nil
                item.isEnabled = false
            }
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
