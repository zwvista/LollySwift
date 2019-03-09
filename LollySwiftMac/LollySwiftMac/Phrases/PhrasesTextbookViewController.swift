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

class PhrasesTextbookViewController: PhrasesBaseViewController {
    
    var wc: PhrasesTextbookWindowController { return view.window!.windowController as! PhrasesTextbookWindowController }
    var vm: PhrasesTextbookViewModel!
    var arrPhrases: [MUnitPhrase] {
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
    
    override func itemForRow(row: Int) -> NSObject? {
        return arrPhrases[row]
    }
    
    override func endEditing(row: Int) {
        let item = arrPhrases[row]
        PhrasesUnitViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
    }
    
    @IBAction func deletePhrase(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = PhrasesTextbookViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editPhrase(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesTextbookDetailViewController") as! PhrasesTextbookDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = vm.arrPhrases[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    override func selectedPhraseChanged() {
        selectedPhrase = tableView.selectedRow == -1 ? "" : vm.arrPhrases[tableView.selectedRow].PHRASE
    }
    
    @IBAction func filterPhrase(_ sender: Any) {
        let n = (sender as! NSSegmentedControl).selectedSegment
        if n == 0 {
            vm.arrPhrasesFiltered = nil
        } else {
            let scope = n == 1 ? "Phrase" : "Translation"
            vm.filterPhrasesForSearchText(wc.filterText, scope: scope)
        }
        self.tableView.reloadData()
    }
}

class PhrasesTextbookWindowController: PhrasesBaseWindowController {
    @IBOutlet weak var scFilter: NSSegmentedControl!
    @IBOutlet weak var tfFilterText: NSTextField!
    @objc var filterText = ""
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window!.toolbar!.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: "No Filter")
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        guard searchfield === tfFilterText else {return}
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        if scFilter.selectedSegment == 0 {
            scFilter.selectedSegment = 1
        }
        (contentViewController as! PhrasesTextbookViewController).filterPhrase(scFilter)
    }
    
    func windowWillClose(_ notification: Notification) {
        tfFilterText.unbindAll()
    }
}
