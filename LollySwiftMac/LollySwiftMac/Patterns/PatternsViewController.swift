//
//  PatternsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import Combine
import AVFAudio

class PatternsViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSMenuItemValidation {

    @IBOutlet weak var scSpeak: NSSegmentedControl!
    @IBOutlet weak var wvWebPage: WKWebView!
    @IBOutlet weak var scScopeFilter: NSSegmentedControl!
    @IBOutlet weak var sfTextFilter: NSSearchField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!
    @IBOutlet var menuPatterns: NSMenu!
    
    var vm: PatternsViewModel!
    let synth = AVSpeechSynthesizer()
    var isSpeaking = true
    var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrPatterns: [MPattern] { vm.arrPatternsFiltered }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
        wvWebPage.allowsMagnification = true
        wvWebPage.allowsBackForwardNavigationGestures = true
        sfTextFilter.searchFieldDidStartSearchingPublisher.sink { [unowned self] in
            vm.textFilter = vmSettings.autoCorrectInput(text: vm.textFilter)
        } ~ subscriptions
    }

    // Hold a reference to the window controller in order to prevent it from being released
    // Without it, we would not be able to access its child controls afterwards
    var wc: PatternsWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
//        wc = view.window!.windowController as? PatternsWindowController
//        wc.scSpeak.selectedSegment = isSpeaking ? 1 : 0
        scSpeak.selectedSegment = isSpeaking ? 1 : 0
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
        if menuItem.action == #selector(editPattern(_:)) {
            return vm.selectedPatternItem != nil
        }
        return true
    }

    @IBAction func copyPattern(_ sender: AnyObject) {
        MacApi.copyText(vm.selectedPattern)
    }

    @IBAction func googlePattern(_ sender: AnyObject) {
        MacApi.googleString(vm.selectedPattern)
    }

    @IBAction func speak(_ sender: AnyObject) {
        let dialogue = AVSpeechUtterance(string: vm.selectedPattern)
        dialogue.voice = AVSpeechSynthesisVoice(identifier: vmSettings.macVoiceName)
        synth.speak(dialogue)
    }

    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! NSSegmentedControl).selectedSegment == 1
        if isSpeaking {
            speak(self)
        }
    }

    func settingsChanged() {
        vm = PatternsViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {}
        vm.$textFilter <~> sfTextFilter.textProperty ~ subscriptions
        vm.$scopeFilter <~> scScopeFilter.selectedLabelProperty ~ subscriptions
        vm.$arrPatternsFiltered.didSet.sink { [unowned self] _ in
            doRefresh()
        } ~ subscriptions
    }
    func doRefresh() {
        tableView.reloadData()
        updateStatusText()
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        Task {
            await vm.reload()
            doRefresh()
        }
    }

    @IBAction func editPattern(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "PatternsDetailViewController") as! PatternsDetailViewController
        detailVC.item = arrPatterns[tableView.selectedRow]
        presentAsModalWindow(detailVC)
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Patterns in \(vmSettings.LANGINFO)"
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
