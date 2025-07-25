//
//  OnlineTextbooksViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import Combine

class OnlineTextbooksViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSMenuItemValidation {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @IBOutlet weak var wvWebPage: WKWebView!
    @objc var textbookFilter = 0

    var vm: OnlineTextbooksViewModel!
    var arrOnlineTextbooks: [MOnlineTextbook] { vm.arrOnlineTextbooks }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
        wvWebPage.allowsMagnification = true
        wvWebPage.allowsBackForwardNavigationGestures = true
    }

    func settingsChanged() {
        vm = OnlineTextbooksViewModel(settings: AppDelegate.theSettingsViewModel)
        refreshTableView(self)
        acTextbooks.content = vm.vmSettings.arrOnlineTextbookFilters
        vm.$arrOnlineTextbooks.didSet.sink { [unowned self] _ in
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
        arrOnlineTextbooks.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrOnlineTextbooks[row]
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        vm.selectedOnlineTextbookItem = row == -1 ? nil : arrOnlineTextbooks[row]
        wvWebPage.load(URLRequest(url: URL(string: vm.selectedOnlineTextbookItem?.URL ?? "")!))
    }

    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(editOnlineTextbook(_:)) {
            return vm.selectedOnlineTextbookItem != nil
        }
        return true
    }

    @IBAction func editOnlineTextbook(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "OnlineTextbooksDetailViewController") as! OnlineTextbooksDetailViewController
        detailVC.item = arrOnlineTextbooks[tableView.selectedRow]
        presentAsModalWindow(detailVC)
    }

    @IBAction func doubleAction(_ sender: AnyObject) {
        editOnlineTextbook(sender)
    }
}
