//
//  WebTextbooksViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import Combine

class WebTextbooksViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @IBOutlet weak var wvWebPage: WKWebView!
    @objc var textbookFilter = 0

    var vm: WebTextbooksViewModel!
    var arrWebTextbooks: [MWebTextbook] { vm.arrWebTextbooksFiltered }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
        wvWebPage.allowsMagnification = true
        wvWebPage.allowsBackForwardNavigationGestures = true
    }

    func settingsChanged() {
        vm = WebTextbooksViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            acTextbooks.content = vm.vmSettings.arrWebTextbookFilters
        }
        vm.$arrWebTextbooksFiltered.didSet.sink { [unowned self] _ in
            doRefresh()
        } ~ subscriptions
    }
    func doRefresh() {
        tableView.reloadData()
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        Task {
            await vm.reload()
            doRefresh()
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

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        if row == -1 {
        } else {
            let item = arrWebTextbooks[row]
            wvWebPage.load(URLRequest(url: URL(string: item.URL)!))
        }
    }

}
