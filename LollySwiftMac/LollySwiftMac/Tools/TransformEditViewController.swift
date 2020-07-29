//
//  TransformEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/28.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa

class TransformEditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var complete: (() -> Void)?
    @objc var vm: TransformEditViewModel!
    var TRANSFORM = ""
    var TEMPLATE = ""

    @IBOutlet weak var tvTranformItems: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = TransformEditViewModel(transform: TRANSFORM, template: TEMPLATE)
        tvTranformItems.reloadData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        vm.arrTranformItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        let item = vm.arrTranformItems[row]
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }
}
