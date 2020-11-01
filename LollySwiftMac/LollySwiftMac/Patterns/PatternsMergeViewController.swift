//
//  PatternsMergeViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/10/30.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa

class PatternsMergeViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tvPatterns: NSTableView!
    @IBOutlet weak var tvPatternVariations: NSTableView!

    var vm: PatternsMergeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPatterns ? vm.arrPatterns.count : vm.arrPatternVariations.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvPatterns {
            let item = vm.arrPatterns[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else if tableView === tvPatternVariations {
            let item = vm.arrPatternVariations[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

}
