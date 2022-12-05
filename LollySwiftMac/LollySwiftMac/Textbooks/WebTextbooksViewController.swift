//
//  WebTextbooksViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class WebTextbooksViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @IBOutlet weak var wvWebPage: WKWebView!

    @objc var textbookFilter = 0

    var vm: WebTextbooksViewModel!
    var arrWebTextbooks: [MWebTextbook] { vm.arrWebTextbooksFiltered ?? vm.arrWebTextbooks }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func settingsChanged() {
        refreshTableView(self)
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm = WebTextbooksViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.acTextbooks.content = self.vm.vmSettings.arrWebTextbookFilters
            self.tableView.reloadData()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        arrWebTextbooks.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrWebTextbooks[row]
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

    @IBAction func filterTextbook(_ sender: AnyObject) {
        vm.applyFilters(textbookFilter: textbookFilter)
        tableView.reloadData()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        if row == -1 {
        } else {
            let item = arrWebTextbooks[row]
            wvWebPage.load(URLRequest(url: URL(string: item.URL)!))
        }
    }

}
