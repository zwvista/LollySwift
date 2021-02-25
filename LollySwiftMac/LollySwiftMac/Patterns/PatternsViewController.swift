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

class PatternsViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSMenuItemValidation, NSToolbarItemValidation {

    @IBOutlet weak var wvWebPage: WKWebView!
    @IBOutlet weak var scScopeFilter: NSSegmentedControl!
    @IBOutlet weak var sfFilter: NSSearchField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tvPatterns: NSTableView!
    @IBOutlet weak var tvWebPages: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!

    var vm: PatternsViewModel!
    var vmWP: PatternsWebPagesViewModel!
    let synth = NSSpeechSynthesizer()
    var isSpeaking = true
    var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPatterns: [MPattern] { vm.arrPatternsFiltered ?? vm.arrPatterns }
    var arrWebPages: [MPatternWebPage] { vmWP.arrWebPages }
    
    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")
    
    func applyFilters() {
        vm.applyFilters()
        self.tvPatterns.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
        wvWebPage.allowsMagnification = true
        wvWebPage.allowsBackForwardNavigationGestures = true
        tvWebPages.registerForDraggedTypes([tableRowDragType])
        _ = vm.textFilter <~> sfFilter.rx.text.orEmpty
        _ = vm.scopeFilter <~> scScopeFilter.rx.selectedLabel
        sfFilter.rx.searchFieldDidStartSearching.subscribe { [unowned self] _ in
            self.vm.textFilter.accept(self.vmSettings.autoCorrectInput(text: self.vm.textFilter.value))
        } ~ rx.disposeBag
        sfFilter.rx.searchFieldDidEndSearching.subscribe { [unowned self] _ in self.applyFilters() } ~ rx.disposeBag
        sfFilter.rx.text.subscribe(onNext: { [unowned self] _ in self.applyFilters() }) ~ rx.disposeBag
        scScopeFilter.rx.selectedLabel.subscribe(onNext: { [unowned self] _ in self.applyFilters() }) ~ rx.disposeBag
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
        super.viewWillDisappear()
        wc = nil
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPatterns ? arrPatterns.count : arrWebPages.count
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let tv = sender.superview!.superview!.superview as! NSTableView
        let row = tv.row(for: sender)
        guard row != -1 else {return}
        let col = tv.column(for: sender)
        let key = tv.tableColumns[col].identifier.rawValue
        let item = (tv === tvPatterns ? arrPatterns[row] : arrWebPages[row]) as NSObject
        let oldValue = String(describing: item.value(forKey: key) ?? "")
        var newValue = sender.stringValue
        if key == "PATTERN" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        if tv === tvPatterns {
            PatternsViewModel.update(item: item as! MPattern).subscribe(onNext: {
                tv.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
            }) ~ rx.disposeBag
        } else if tv === tvWebPages {
            PatternsWebPagesViewModel.updateWebPage(item: item as! MPatternWebPage).subscribe(onNext: {
                tv.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
            }) ~ rx.disposeBag
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
        }
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvPatterns {
            updateStatusText()
            let row = tvPatterns.selectedRow
            vm.selectedPatternItem = row == -1 ? nil : arrPatterns[row]
            vmWP.selectedPatternItem = vm.selectedPatternItem
            vmWP.getWebPages().subscribe(onNext: {
                self.tvWebPages.reloadData()
                if self.tvWebPages.numberOfRows > 0 {
                    self.tvWebPages.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                }
            }) ~ rx.disposeBag
            if isSpeaking {
                speak(self)
            }
        } else if tv === tvWebPages {
            let row = tvWebPages.selectedRow
            if row == -1 {
            } else {
                let item = arrWebPages[row]
                wvWebPage.load(URLRequest(url: URL(string: item.URL)!))
            }
        }
    }
    
    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }

    // https://stackoverflow.com/questions/8017822/how-to-enable-disable-nstoolbaritem
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        let s = item.paletteLabel
        let enabled = !(s == "Add WebPage" && vm.selectedPatternID == 0)
        return enabled
    }

    @IBAction func copyPattern(_ sender: AnyObject) {
        MacApi.copyText(vm.selectedPattern)
    }
    
    @IBAction func googlePattern(_ sender: AnyObject) {
        MacApi.googleString(vm.selectedPattern)
    }
    
    @IBAction func speak(_ sender: AnyObject) {
        synth.startSpeaking(vm.selectedPattern)
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
        vmWP = PatternsWebPagesViewModel(settings: vm.vmSettings, needCopy: false)
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
    }
    func doRefresh() {
        tvPatterns.reloadData()
        updateStatusText()
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }
    
    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPattern(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "PatternsDetailViewController") as! PatternsDetailViewController
        editVC.vm = vm
        editVC.item = vm.newPattern()
        editVC.complete = { self.tvPatterns.reloadData(); self.addPattern(self) }
        self.presentAsSheet(editVC)
    }

    @IBAction func editPattern(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "PatternsDetailViewController") as! PatternsDetailViewController
        editVC.vm = vm
        let i = tvPatterns.selectedRow
        editVC.item = arrPatterns[i]
        editVC.complete = {
            self.tvPatterns.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
    }

    @IBAction func addWebPage(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PatternsWebPagesDetailViewController") as! PatternsWebPagesDetailViewController
        detailVC.vm = vm
        detailVC.item = vmWP.newPatternWebPage()
        detailVC.complete = { self.tvWebPages.reloadData(); self.addWebPage(self) }
        self.presentAsSheet(detailVC)
    }

    @IBAction func editWebPage(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PatternsWebPagesDetailViewController") as! PatternsWebPagesDetailViewController
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
        editPattern(sender)
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
            vmWP.arrWebPages.moveElement(at: oldIndex, to: newIndex)
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
        let col = tableView.tableColumns.firstIndex { $0.identifier.rawValue == "SEQNUM" }!
        vmWP.reindexWebPage {
            tableView.reloadData(forRowIndexes: [$0], columnIndexes: [col])
        }
        tableView.endUpdates()
        
        return true
    }
    
    @IBAction func mergePatterns(_ sender: AnyObject) {
        let mergeVC = self.storyboard!.instantiateController(withIdentifier: "PatternsMergeViewController") as! PatternsMergeViewController
        let items = tvPatterns.selectedRowIndexes.map { arrPatterns[$0] }
        mergeVC.vm = PatternsMergeViewModel(items: items)
        self.presentAsModalWindow(mergeVC)
    }
    
    @IBAction func splitPattern(_ sender: AnyObject) {
        let splitVC = self.storyboard!.instantiateController(withIdentifier: "PatternsSplitViewController") as! PatternsSplitViewController
        self.presentAsModalWindow(splitVC)
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
