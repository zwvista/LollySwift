//
//  LangBlogSelectGroupsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/04/05.
//  Copyright © 2020 趙偉. Available rights reserved.
//

import Cocoa
import Combine

class LangBlogSelectGroupsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tvAvailable: NSTableView!
    @IBOutlet weak var tvSelected: NSTableView!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnRemoveAll: NSButton!

    var item: MLangBlogPost!
    var vm: LangBlogSelectGroupsViewModel!
    var complete: (() -> Void)?
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = LangBlogSelectGroupsViewModel(item: item) { [unowned self] in
            tvAvailable.reloadData()
            tvSelected.reloadData()
        }
        func updateUI() {
            tvAvailable.reloadData()
            tvSelected.reloadData()
        }

        btnAdd.tapPublisher.sink { [unowned self] in
            let arr = tvAvailable.selectedRowIndexes.map { vm.groupsAvailable[$0] }
            guard !arr.isEmpty else {return}
            vm.addGroups(arr: arr)
            updateUI()
        } ~ subscriptions
        btnRemove.tapPublisher.sink { [unowned self] in
            let arr = tvSelected.selectedRowIndexes.map { vm.groupsSelected[$0] }
            guard !arr.isEmpty else {return}
            vm.removeGroups(arr: arr)
            updateUI()
        } ~ subscriptions
        btnRemoveAll.tapPublisher.sink { [unowned self] in
            vm.removeAllGroups()
            updateUI()
        } ~ subscriptions

        btnOK.tapPublisher.sink { [unowned self] in
            Task {
                await vm.onOK()
                complete?()
                dismiss(btnOK)
            }
        } ~ subscriptions
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Select Groups"
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvAvailable ? vm.groupsAvailable.count : vm.groupsSelected.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvAvailable {
            let item = vm.groupsAvailable[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = vm.groupsSelected[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
