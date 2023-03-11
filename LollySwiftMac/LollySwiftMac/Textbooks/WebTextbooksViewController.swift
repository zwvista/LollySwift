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
import RxBinding

class WebTextbooksViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSMenuItemValidation {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @IBOutlet weak var wvWebPage: WKWebView!

    @objc var textbookFilter = 0

    var vm: WebTextbooksViewModel!
    var arrWebTextbooks: [MWebTextbook] { vm.arrWebTextbooksFiltered }

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
        vm.arrWebTextbooksFiltered_.subscribe { [unowned self] _ in
            doRefresh()
        } ~ rx.disposeBag
    }
    func doRefresh() {
        tableView.reloadData()
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe { [unowned self] _ in
            doRefresh()
        } ~ rx.disposeBag
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
        vm.selectedWebTextbookItem = row == -1 ? nil : arrWebTextbooks[row]
        wvWebPage.load(URLRequest(url: URL(string: vm.selectedWebTextbookItem?.URL ?? "")!))
    }

    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(editWebTextbook(_:)) {
            return vm.selectedWebTextbookItem != nil
        }
        return true
    }

    @IBAction func editWebTextbook(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "WebTextbooksDetailViewController") as! WebTextbooksDetailViewController
        detailVC.item = arrWebTextbooks[tableView.selectedRow]
        presentAsModalWindow(detailVC)
    }

    @IBAction func doubleAction(_ sender: AnyObject) {
        editWebTextbook(sender)
    }
}
