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

class PhrasesLangViewController: PhrasesViewController {
    
    var wc: PhrasesLangWindowController { return view.window!.windowController as! PhrasesLangWindowController }
    var vm: PhrasesLangViewModel!
    var arrPhrases: [MLangPhrase] {
        return vm.arrPhrasesFiltered == nil ? vm.arrPhrases : vm.arrPhrasesFiltered!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTableView(self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrPhrases.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrPhrases[row]
        let columnName = tableColumn!.title
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell;
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].title
        let item = arrPhrases[row]
        let oldValue = String(describing: item.value(forKey: key)!)
        var newValue = sender.stringValue
        if key == "PHRASE" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        PhrasesLangViewModel.update(item: item).subscribe().disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newLangPhrase()
        detailVC.complete = { self.tableView.reloadData(); self.addPhrase(self) }
        self.presentAsSheet(detailVC)
    }
    
    @IBAction func deletePhrase(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = PhrasesLangViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editPhrase(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = vm.arrPhrases[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func copyPhrase(_ sender: Any) {
        let item = vm.arrPhrases[tableView.selectedRow]
        MacApi.copyText(item.PHRASE)
    }
    
    @IBAction func googlePhrase(_ sender: Any) {
        let item = vm.arrPhrases[tableView.selectedRow]
        MacApi.googleString(item.PHRASE)
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
    
    override func settingsChanged() {
        refreshTableView(self)
    }
}

class PhrasesLangWindowController: NSWindowController, NSTextFieldDelegate {
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
        (contentViewController as! PhrasesLangViewController).filterPhrase(scFilter)
    }
}

