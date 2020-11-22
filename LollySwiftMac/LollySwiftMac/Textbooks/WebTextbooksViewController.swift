//
//  WebTextbooksViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class WebTextbooksViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView!

    var vm: WebTextbooksViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func settingsChanged() {
        refreshTableView(self)
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm = WebTextbooksViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.tableView.reloadData()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        vm.arrWebTextbooks.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = vm.arrWebTextbooks[row]
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

}
