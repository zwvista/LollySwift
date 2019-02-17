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
    var selectedDictGroupIndex = 0
    
    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var tfNewWord: NSTextField!
    @IBOutlet weak var tableView: NSTableView!

    let disposeBag = DisposeBag()
    
    @objc var newWord = ""
    var selectedWord = ""
    var status = DictWebViewStatus.ready
    let synth = NSSpeechSynthesizer()
    var speakOrNot = false

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        guard searchfield === tfNewWord else {return}
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        addNewWord()
    }
    
    @IBAction func searchNewWord(_ sender: AnyObject) {
        commitEditing()
        guard !newWord.isEmpty else {return}
        searchWord(word: newWord)
    }
    
    func searchWord(word: String) {
        selectedWord = word
        status = .ready
        let item = vmSettings.arrDictsGroup[selectedDictGroupIndex]
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
                    status = .navigating
                }
            }
        }
    }
    
    @IBAction func searchDict(_ sender: Any) {
        if sender is NSToolbarItem {
            let tbItem = sender as! NSToolbarItem
            selectedDictGroupIndex = tbItem.tag
            print(tbItem.toolbar!.selectedItemIdentifier!.rawValue)
        }
        if tableView.selectedRow == -1 {
            searchWord(word: newWord)
        } else {
            searchWordInTableView()
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        searchDict(self)
        if speakOrNot {
            speak(self)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.window?.makeKeyAndOrderFront(self)
        tableView.becomeFirstResponder()
        guard status == .navigating else {return}
        let item = vmSettings.arrDictsGroup[selectedDictGroupIndex]
        let item2 = vmSettings.arrDictsMean.first { $0.DICTNAME == item.DICTNAME }!
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
            print(html)
            let str = item2.htmlString(html, word: self.selectedWord)
            self.wvDict.loadHTMLString(str, baseURL: nil)
            self.status = .ready
        }
    }
    
    @IBAction func addNewWord(_ sender: Any) {
        addNewWord()
    }

    func addNewWord() {
    }
    
    func searchWordInTableView() {
    }

    func settingsChanged() {
        selectedDictGroupIndex = vmSettings.selectedDictGroupIndex
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.selectedLang.safeVoice))
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
        let item = vmSettings.arrDictsGroup[selectedDictGroupIndex]
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

class WordsWindowController: NSWindowController, NSToolbarDelegate, LollyProtocol, NSWindowDelegate {
    
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
            if i < vmSettings.arrDictsGroup.count {
                let item = toolbar.items[defaultToolbarItemCount + i]
                item.label = vmSettings.arrDictsGroup[i].DICTNAME
                item.target = contentViewController
                item.action = #selector(WordsBaseViewController.searchDict(_:))
                item.isEnabled = true
                item.image = img
                if i == vmSettings.selectedDictGroupIndex {
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
