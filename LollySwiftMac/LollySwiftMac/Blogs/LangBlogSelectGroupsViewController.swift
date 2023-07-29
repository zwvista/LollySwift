//
//  LangBlogSelectGroupsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/04/05.
//  Copyright © 2020 趙偉. Available rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class LangBlogSelectGroupsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tvAvailable: NSTableView!
    @IBOutlet weak var tvSelected: NSTableView!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnRemoveAll: NSButton!

    var vm: SettingsViewModel { AppDelegate.theSettingsViewModel }
    var dictsAvailable: [MDictionary]!
    var dictsSelected: [MDictionary]!
    var complete: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        dictsSelected = vm.selectedDictsReference
        updateDictsAvailable()

        func updateDictsAvailable() {
            dictsAvailable = vm.arrDictsReference.filter { d in !dictsSelected.contains { $0.DICTNAME == d.DICTNAME } }
        }
        func updateDictsAvailableAndUI() {
            updateDictsAvailable()
            tvAvailable.reloadData()
            tvSelected.reloadData()
        }

        btnAdd.rx.tap.subscribe { [unowned self] _ in
            for i in tvAvailable.selectedRowIndexes {
                dictsSelected.append(dictsAvailable[i])
            }
            updateDictsAvailableAndUI()
        } ~ rx.disposeBag
        btnRemove.rx.tap.subscribe { [unowned self] _ in
            for i in tvSelected.selectedRowIndexes.reversed() {
                dictsSelected.remove(at: i)
            }
            updateDictsAvailableAndUI()
        } ~ rx.disposeBag
        btnRemoveAll.rx.tap.subscribe { [unowned self] _ in
            dictsSelected.removeAll()
            updateDictsAvailableAndUI()
        } ~ rx.disposeBag

        btnOK.rx.tap.flatMap { [unowned self] in
            vm.selectedDictsReferenceIndexes = dictsSelected.compactMap { o in vm.arrDictsReference.firstIndex { $0.DICTID == o.DICTID } }
            return vm.updateDictsReference()
        }.subscribe { [unowned self] _ in
            complete?()
            dismiss(btnOK)
        } ~ rx.disposeBag
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Select Dictionaries"
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvAvailable ? dictsAvailable.count : dictsSelected.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvAvailable {
            let item = dictsAvailable[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = dictsSelected[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
