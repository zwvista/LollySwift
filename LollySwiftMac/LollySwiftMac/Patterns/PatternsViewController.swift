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
import RxBinding

class PatternsViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSMenuItemValidation, NSToolbarItemValidation {

    @IBOutlet weak var wvWebPage: WKWebView!
    @IBOutlet weak var scScopeFilter: NSSegmentedControl!
    @IBOutlet weak var sfTextFilter: NSSearchField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!

    var vm: PatternsViewModel!
    let synth = NSSpeechSynthesizer()
    var isSpeaking = true
    var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPatterns: [MPattern] { vm.arrPatternsFiltered }

    // https://developer.apple.com/videos/play/wwdc2011/120/
    // https://stackoverflow.com/questions/2121907/drag-drop-reorder-rows-on-nstableview
    let tableRowDragType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
        wvWebPage.allowsMagnification = true
        wvWebPage.allowsBackForwardNavigationGestures = true
        sfTextFilter.rx.searchFieldDidStartSearching.subscribe { [unowned self] _ in
            vm.textFilter = vmSettings.autoCorrectInput(text: vm.textFilter)
        } ~ rx.disposeBag
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
        sfTextFilter?.placeholderString = "Filter"
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        wc = nil
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        arrPatterns.count
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        let tv = sender.superview!.superview!.superview as! NSTableView
        let row = tv.row(for: sender)
        guard row != -1 else {return}
        let col = tv.column(for: sender)
        let key = tv.tableColumns[col].identifier.rawValue
        let item = arrPatterns[row]
        let oldValue = String(describing: item.value(forKey: key) ?? "")
        var newValue = sender.stringValue
        if key == "PATTERN" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        PatternsViewModel.update(item: item).subscribe { [unowned self] _ in
            tv.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<tableView.tableColumns.count))
        } ~ rx.disposeBag
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        let item = arrPatterns[row]
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        vm.selectedPatternItem = row == -1 ? nil : arrPatterns[row]
        wvWebPage.load(URLRequest(url: URL(string: vm.selectedPatternItem?.URL ?? "")!))
        if isSpeaking {
            speak(self)
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
        vm = PatternsViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            doRefresh()
        }
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
        _ = vm.textFilter_ <~> sfTextFilter.rx.text.orEmpty
        _ = vm.scopeFilter_ <~> scScopeFilter.rx.selectedLabel
        vm.arrPatternsFiltered_.subscribe { [unowned self] _ in
            doRefresh()
        } ~ rx.disposeBag
    }
    func doRefresh() {
        tableView.reloadData()
        updateStatusText()
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe { [unowned self] _ in
            doRefresh()
        } ~ rx.disposeBag
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPattern(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "PatternsDetailViewController") as! PatternsDetailViewController
        detailVC.vmEdit = PatternsDetailViewModel(vm: vm, item: vm.newPattern())
        detailVC.complete = { [unowned self] in tableView.reloadData(); addPattern(self) }
        presentAsSheet(detailVC)
    }

    @IBAction func editPattern(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "PatternsDetailViewController") as! PatternsDetailViewController
        let i = tableView.selectedRow
        detailVC.vmEdit = PatternsDetailViewModel(vm: vm, item: arrPatterns[i])
        detailVC.complete = { [unowned self] in
            tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tableView.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Patterns"
    }

    @IBAction func doubleAction(_ sender: AnyObject) {
        editPattern(sender)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class PatternsWindowController: NSWindowController, LollyProtocol, NSWindowDelegate, NSTextFieldDelegate {

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var scSpeak: NSSegmentedControl!
    func settingsChanged() {
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
