//
//  PatternsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift
import NSObject_Rx

class PatternsViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSMenuItemValidation, NSToolbarItemValidation {

    @IBOutlet weak var wvWebPage: WKWebView!
    @IBOutlet weak var tfNewPattern: NSTextField!
    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var sfFilter: NSSearchField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tvPatterns: NSTableView!
    @IBOutlet weak var tvWebPages: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!
    @IBOutlet weak var tvPhrases: NSTableView!

    var vm: PatternsViewModel!
    @objc var newPattern = ""
    @objc var textFilter = ""
    var selectedPattern = ""
    var selectedPatternID = 0
    let synth = NSSpeechSynthesizer()
    var isSpeaking = true
    var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPatterns: [MPattern] { vm.arrPatternsFiltered ?? vm.arrPatterns }
    var arrWebPages: [MPatternWebPage] { vm.arrWebPages }
    var arrPhrases: [MPatternPhrase] { vm.arrPhrases }
    
    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
        wvWebPage.allowsMagnification = true
        wvWebPage.allowsBackForwardNavigationGestures = true
        tvWebPages.registerForDraggedTypes([tableRowDragType])
    }
    
    // Hold a reference to the window controller in order to prevent it from being released
    // Without it, we would not be able to access its child controls afterwards
    var wc: PatternsWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
        wc = view.window!.windowController as? PatternsWindowController
        wc.scSpeak.selectedSegment = isSpeaking ? 1 : 0
        // For some unknown reason, the placeholder string of the filter text field
        // cannot be set in the storyboard
        // https://stackoverflow.com/questions/5519512/nstextfield-placeholder-text-doesnt-show-unless-editing
        sfFilter?.placeholderString = "Filter"
    }
    override func viewWillDisappear() {
        wc = nil
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPatterns ? arrPatterns.count : tableView === tvWebPages ? arrWebPages.count : arrPhrases.count
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let tv = sender.superview!.superview!.superview as! NSTableView
        let row = tv.row(for: sender)
        guard row != -1 else {return}
        let col = tv.column(for: sender)
        let key = tv.tableColumns[col].identifier.rawValue
        let item = (tv === tvPatterns ? arrPatterns[row] : tv === tvWebPages ? arrWebPages[row] : arrPhrases[row]) as NSObject
        let oldValue = String(describing: item.value(forKey: key) ?? "")
        var newValue = sender.stringValue
        if key == "PATTERN" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        if tv === tvPatterns {
            PatternsViewModel.update(item: item as! MPattern).subscribe {
                tv.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
            } ~ rx.disposeBag
        } else if tv === tvWebPages {
            PatternsViewModel.updateWebPage(item: item as! MPatternWebPage).subscribe {
                tv.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
            } ~ rx.disposeBag
        } else if tv == tvPhrases {
            PatternsViewModel.updatePhrase(item: item as! MPatternPhrase).subscribe {
                tv.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
            } ~ rx.disposeBag
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvPatterns {
            let item = arrPatterns[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else if tableView === tvWebPages {
            let item = arrWebPages[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = arrPhrases[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvPatterns {
            updateStatusText()
            let row = tvPatterns.selectedRow
            if row == -1 {
                selectedPattern = ""
                selectedPatternID = 0
                vm.arrWebPages = []
                tvWebPages.reloadData()
                vm.arrPhrases = []
                tvPhrases.reloadData()
            } else {
                let item = arrPatterns[row]
                selectedPattern = item.PATTERN
                selectedPatternID = item.ID
                vm.getWebPages(patternid: selectedPatternID).subscribe {
                    self.tvWebPages.reloadData()
                    if self.tvWebPages.numberOfRows > 0 {
                        self.tvWebPages.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                    }
                } ~ rx.disposeBag
                searchPhrases()
                if isSpeaking {
                    speak(self)
                }
            }
        } else if tv === tvWebPages {
            let row = tvWebPages.selectedRow
            if row == -1 {
            } else {
                let item = arrWebPages[row]
                wvWebPage.load(URLRequest(url: URL(string: item.URL)!))
            }
        } else {
            let row = tvPhrases.selectedRow
            if isSpeaking && row != -1 {
                synth.startSpeaking(arrPhrases[row].PHRASE)
            }
        }
    }
    
    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(selectPhrases(_:)) {
            return selectedPatternID != 0
        }
        return true
    }

    // https://stackoverflow.com/questions/8017822/how-to-enable-disable-nstoolbaritem
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        let s = item.paletteLabel
        let enabled = !((s == "Add WebPage" || s == "Select Phrase") && selectedPatternID == 0)
        return enabled
    }

    @IBAction func copyPattern(_ sender: AnyObject) {
        MacApi.copyText(selectedPattern)
    }
    
    @IBAction func googlePattern(_ sender: AnyObject) {
        MacApi.googleString(selectedPattern)
    }
    
    @IBAction func speak(_ sender: AnyObject) {
        synth.startSpeaking(selectedPattern)
    }
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! NSSegmentedControl).selectedSegment == 1
        if isSpeaking {
            speak(self)
        }
    }

    func settingsChanged() {
        vm = PatternsViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.doRefresh()
        }
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
    }
    func doRefresh() {
        tvPatterns.reloadData()
        updateStatusText()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        if textfield === tfNewPattern {
            guard !newPattern.isEmpty else {return}
            let item = vm.newPattern()
            item.PATTERN = vm.vmSettings.autoCorrectInput(text: newPattern)
            PatternsViewModel.create(item: item).subscribe(onNext: {
                item.ID = $0
                self.vm.arrPatterns.append(item)
                self.tvPatterns.reloadData()
                self.tfNewPattern.stringValue = ""
                self.newPattern = ""
            }) ~ rx.disposeBag
        } else if textfield === sfFilter {
            if !textFilter.isEmpty {
                scTextFilter.selectedSegment = 1
                textFilter = vmSettings.autoCorrectInput(text: textFilter)
                sfFilter.stringValue = textFilter
            }
            scTextFilter.performClick(self)
        }
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe {
            self.doRefresh()
        } ~ rx.disposeBag
    }
    
    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPattern(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PatternsDetailViewController") as! PatternsDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newPattern()
        detailVC.complete = { self.tvPatterns.reloadData(); self.addPattern(self) }
        self.presentAsSheet(detailVC)
    }

    @IBAction func editPattern(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PatternsDetailViewController") as! PatternsDetailViewController
        detailVC.vm = vm
        let i = tvPatterns.selectedRow
        detailVC.item = MPattern()
        detailVC.item.copy(from: arrPatterns[i])
        detailVC.complete = {
            self.arrPatterns[i].copy(from: detailVC.item)
            self.tvPatterns.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }

    @IBAction func addWebPage(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PatternsWebPageViewController") as! PatternsWebPageViewController
        detailVC.vm = vm
        detailVC.item = vm.newPatternWebPage(patternid: selectedPatternID, pattern: selectedPattern)
        detailVC.complete = { self.tvWebPages.reloadData(); self.addWebPage(self) }
        self.presentAsSheet(detailVC)
    }

    @IBAction func editWebPage(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PatternsWebPageViewController") as! PatternsWebPageViewController
        detailVC.vm = vm
        let i = tvWebPages.selectedRow
        detailVC.item = MPatternWebPage()
        detailVC.item.copy(from: arrWebPages[i])
        detailVC.complete = {
            self.arrWebPages[i].copy(from: detailVC.item)
            self.tvWebPages.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvWebPages.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tvPatterns.numberOfRows) Patterns"
    }
    
    @IBAction func doubleAction(_ sender: AnyObject) {
        if NSApp.currentEvent!.modifierFlags.contains(.option) {
            selectPhrases(sender)
        } else {
            editPattern(sender)
        }
    }

    @IBAction func selectPhrases(_ sender: AnyObject) {
        let detailVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesSelectLangViewController") as! PhrasesSelectLangViewController
        detailVC.textFilter = selectedPattern
        detailVC.patternid = selectedPatternID
        detailVC.complete = {
            self.searchPhrases()
        }
        self.presentAsModalWindow(detailVC)
    }
    
    func searchPhrases() {
        vm.searchPhrases(patternid: selectedPatternID).subscribe {
            self.tvPhrases.reloadData()
        } ~ rx.disposeBag
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if tableView === tvWebPages {
            let item = NSPasteboardItem()
            item.setString(String(row), forType: tableRowDragType)
            return item
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { (draggingItem, _, _) in
            if let str = (draggingItem.item as! NSPasteboardItem).string(forType: self.tableRowDragType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }
        
        var oldIndexOffset = 0
        var newIndexOffset = 0
        
        func moveRow(at oldIndex: Int, to newIndex: Int) {
            vm.moveWebPage(at: oldIndex, to: newIndex)
            tableView.moveRow(at: oldIndex, to: newIndex)
        }
        
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                oldIndexOffset -= 1
            } else {
                moveRow(at: oldIndex, to: row + newIndexOffset)
                newIndexOffset += 1
            }
        }
        let col = tableView.tableColumns.firstIndex { $0.title == "SEQNUM" }!
        vm.reindexWebPage {
            tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
        }
        tableView.endUpdates()
        
        return true
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PatternsWindowController: NSWindowController, LollyProtocol, NSWindowDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var scSpeak: NSSegmentedControl!
    func settingsChanged() {
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
