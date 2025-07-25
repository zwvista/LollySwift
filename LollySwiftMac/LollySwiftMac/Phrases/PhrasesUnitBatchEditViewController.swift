//
//  PhrasesUnitBatchEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import Combine

class PhrasesUnitBatchEditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var chkUnit: NSButton!
    @IBOutlet weak var chkPart: NSButton!
    @IBOutlet weak var chkSeqNum: NSButton!
    @IBOutlet weak var btnCheckAll: NSButton!
    @IBOutlet weak var btnUncheckAll: NSButton!
    @IBOutlet weak var btnCheckSelected: NSButton!
    @IBOutlet weak var btnUncheckSelected: NSButton!
    @IBOutlet weak var btnOK: NSButton!

    var vmEdit: PhrasesUnitBatchEditViewModel!
    var vmSettings: SettingsViewModel { vmEdit.vm.vmSettings }
    var complete: (() -> Void)?
    var arrPhrases: [MUnitPhrase] { vmEdit.vm.arrPhrasesAll }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = vmSettings.arrUnits
        acParts.content = vmSettings.arrParts
        vmEdit.$indexUNIT <~> pubUnit.selectedItemIndexProperty ~ subscriptions
        vmEdit.$indexPART <~> pubPart.selectedItemIndexProperty ~ subscriptions
        vmEdit.$SEQNUM <~> tfSeqNum.textProperty ~ subscriptions
        vmEdit.$unitChecked <~> chkUnit.isOnProperty ~ subscriptions
        vmEdit.$partChecked <~> chkPart.isOnProperty ~ subscriptions
        vmEdit.$seqnumChecked <~> chkSeqNum.isOnProperty ~ subscriptions
        vmEdit.$unitChecked ~> (pubUnit, \.isEnabled) ~ subscriptions
        vmEdit.$partChecked ~> (pubPart, \.isEnabled) ~ subscriptions
        vmEdit.$seqnumChecked ~> (tfSeqNum, \.isEnabled) ~ subscriptions

        func checkItems(_ btn: NSButton) {
            for i in 0..<tableView.numberOfRows {
                let chk = (tableView.view(atColumn: 0, row: i, makeIfNecessary: true)! as! LollyCheckCell).chk!
                chk.state =
                    btn === btnCheckAll ? .on :
                    btn === btnUncheckAll ? .off :
                    !tableView.selectedRowIndexes.contains(i) ? chk.state :
                    btn === btnCheckSelected ? .on : .off
            }
        }
        for btn in [btnCheckAll, btnUncheckAll, btnCheckSelected, btnUncheckSelected] {
            btn!.tapPublisher.sink { _ in checkItems(btn!) } ~ subscriptions
        }

        btnOK.tapPublisher.sink { [unowned self] in
            // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
            commitEditing()
            var rows = [Bool]()
            for i in 0..<tableView.numberOfRows {
                let chk = (tableView.view(atColumn: 0, row: i, makeIfNecessary: true)! as! LollyCheckCell).chk!
                rows.append(chk.state == .on)
            }
            Task {
                await vmEdit.onOK(rows: rows)
                complete?()
                dismiss(btnOK)
            }
        } ~ subscriptions
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        view.window?.title = "Batch Edit"
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        arrPhrases.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrPhrases[row]
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
