//
//  DictsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa

class DictsViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    @IBOutlet weak var tableView: NSTableView!

    var vm: DictsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func settingsChanged() {
        refreshTableView(self)
    }

    @IBAction func refreshTableView(_ sender: Any) {
        vm = DictsViewModel(settings: AppDelegate.theSettingsViewModel) { [unowned self] in
            tableView.reloadData()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        vm.arrDicts.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = vm.arrDicts[row]
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

    @IBAction func editDict(_ sender: Any) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "DictsDetailViewController") as! DictsDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = vm.arrDicts[i]
        detailVC.complete = { [unowned self] in tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tableView.tableColumns.count)) }
        presentAsModalWindow(detailVC)
    }

    @IBAction func addDict(_ sender: Any) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "DictsDetailViewController") as! DictsDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newDict()
        detailVC.complete = { [unowned self] in tableView.reloadData() }
        presentAsSheet(detailVC)
    }

    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        guard row != -1 else {return}
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].identifier.rawValue
        let item = vm.arrDicts[row]
        let oldValue = String(describing: item.value(forKey: key) ?? "")
        let newValue = sender.stringValue
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        Task {
            await DictsViewModel.update(item: item)
            tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<tableView.tableColumns.count))
        }
    }
}
