//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class PhrasesLangViewController: PhrasesBaseViewController {
    
    var wc: PhrasesLangWindowController { return view.window!.windowController as! PhrasesLangWindowController }
    var vm: PhrasesLangViewModel!
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrPhrases: [MLangPhrase] {
        return vm.arrPhrasesFiltered == nil ? vm.arrPhrases : vm.arrPhrasesFiltered!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func settingsChanged() {
        refreshTableView(self)
        super.settingsChanged()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrPhrases.count
    }
    
    override func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        return arrPhrases[row]
    }
    
    override func endEditing(row: Int) {
        let item = arrPhrases[row]
        PhrasesLangViewModel.update(item: item).subscribe().disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newLangPhrase()
        detailVC.complete = { self.tableView.reloadData(); self.addPhrase(self) }
        self.presentAsSheet(detailVC)
    }

    override func deletePhrase(row: Int) {
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm = PhrasesLangViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editPhrase(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = arrPhrases[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    override func selectedPhraseChanged() {
        selectedPhrase = tableView.selectedRow == -1 ? "" : vm.arrPhrases[tableView.selectedRow].PHRASE
    }
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        let n = (sender as! NSSegmentedControl).selectedSegment
        if n == 0 {
            vm.arrPhrasesFiltered = nil
        } else {
            let scope = n == 1 ? "Phrase" : "Translation"
            vm.filterPhrasesForSearchText(wc.textFilter, scope: scope)
        }
        self.tableView.reloadData()
    }
}

class PhrasesLangWindowController: PhrasesBaseWindowController {
    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var tfFilter: NSTextField!
    @objc var textFilter = ""

    override func windowDidLoad() {
        super.windowDidLoad()
        window!.toolbar!.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: "No Filter")
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
            textFilter = vm.autoCorrectInput(text: textFilter)
            tfFilter.stringValue = textFilter
        }
        (contentViewController as! PhrasesLangViewController).filterPhrase(scTextFilter)
    }
    
    func windowWillClose(_ notification: Notification) {
        tfFilter.unbindAll()
    }
}

