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

class PhrasesLangViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var timer = Timer()
    @objc
    var newPhrase = ""
    
    var vm: PhrasesLangViewModel!
    var arrPhrases: [MLangPhrase] {
        return vm.arrPhrases
    }
    
    let disposeBag = DisposeBag()

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
        let newValue = sender.stringValue
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        PhrasesLangViewModel.update(item: item).subscribe().disposed(by: disposeBag)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.window?.makeKeyAndOrderFront(self)
        tableView.becomeFirstResponder()
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPhrase(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesLangDetailViewController") as! PhrasesLangDetailViewController
        detailVC.vm = vm
        detailVC.mPhrase = vm.newLangPhrase()
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
        detailVC.mPhrase = vm.arrPhrases[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func copyPhrase(_ sender: Any) {
        let item = vm.arrPhrases[tableView.selectedRow]
        MacApi.copyText(item.PHRASE)
    }
    
    @IBAction func googlePhrase(_ sender: Any) {
        let item = vm.arrPhrases[tableView.selectedRow]
        NSWorkspace.shared.open([URL(string: "https://www.google.com/search?q=\(item.PHRASE)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!],
                                withAppBundleIdentifier:"com.apple.Safari",
                                options: [],
                                additionalEventParamDescriptor: nil,
                                launchIdentifiers: nil)
    }
    
    func settingsChanged() {
        refreshTableView(self)
    }
}

class PhrasesLangWindowController: NSWindowController, LollyProtocol {
    
    var vc: PhrasesLangViewController {return contentViewController as! PhrasesLangViewController}
    @objc var vm: SettingsViewModel {return vmSettings}
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func settingsChanged() {
        
    }
}

