//
//  TextbooksViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import Combine

class TextbooksViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    @IBOutlet weak var tableView: NSTableView!

    var vm: TextbooksViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func settingsChanged() {
        refreshTableView(self)
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm = TextbooksViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            tableView.reloadData()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        vm.arrTextbooks.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = vm.arrTextbooks[row]
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

    @IBAction func editTextbook(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "TextbooksDetailViewController") as! TextbooksDetailViewController
        let i = tableView.selectedRow
        detailVC.vmEdit = TextbooksDetailViewModel(vm: vm, item: vm.arrTextbooks[i])
        detailVC.complete = { [unowned self] in tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tableView.tableColumns.count)) }
        presentAsModalWindow(detailVC)
    }

    @IBAction func addTextbook(_ sender: AnyObject) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "TextbooksDetailViewController") as! TextbooksDetailViewController
        detailVC.vmEdit = TextbooksDetailViewModel(vm: vm, item: vm.newTextbook())
        detailVC.complete = { [unowned self] in tableView.reloadData() }
        presentAsModalWindow(detailVC)
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        guard row != -1 else {return}
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].identifier.rawValue
        let item = vm.arrTextbooks[row]
        let oldValue = String(describing: item.value(forKey: key) ?? "")
        let newValue = sender.stringValue
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        Task {
            await TextbooksViewModel.update(item: item)
            tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<tableView.tableColumns.count))
        }
    }
}
