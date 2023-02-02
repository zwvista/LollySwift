//
//  PhrasesUnitBatchEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

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
    @IBOutlet weak var btnOK: NSButton!

    var vmEdit: PhrasesUnitBatchEditViewModel!
    var vmSettings: SettingsViewModel { vmEdit.vm.vmSettings }
    var complete: (() -> Void)?
    var arrPhrases: [MUnitPhrase] { vmEdit.vm.arrPhrases }

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = vmSettings.arrUnits
        acParts.content = vmSettings.arrParts
        _ = vmEdit.indexUNIT <~> pubUnit.rx.selectedItemIndex
        _ = vmEdit.indexPART <~> pubPart.rx.selectedItemIndex
        _ = vmEdit.SEQNUM <~> tfSeqNum.rx.text.orEmpty
        _ = vmEdit.unitChecked <~> chkUnit.rx.isOn
        _ = vmEdit.partChecked <~> chkPart.rx.isOn
        _ = vmEdit.seqnumChecked <~> chkSeqNum.rx.isOn
        _ = vmEdit.unitChecked ~> pubUnit.rx.isEnabled
        _ = vmEdit.partChecked ~> pubPart.rx.isEnabled
        _ = vmEdit.seqnumChecked ~> tfSeqNum.rx.isEnabled
        btnOK.rx.tap.flatMap { [unowned self] _ -> Single<()> in
            // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
            commitEditing()
            var rows = [Bool]()
            for i in 0..<tableView.numberOfRows {
                let chk = (tableView.view(atColumn: 0, row: i, makeIfNecessary: false)! as! LollyCheckCell).chk!
                rows.append(chk.state == .on)
            }
            return vmEdit.onOK(rows: rows)
        }.subscribe { [unowned self] _ in
            complete?()
            dismiss(btnOK)
        } ~ rx.disposeBag
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

    @IBAction func checkItems(_ sender: AnyObject) {
        let n = (sender as! NSButton).tag
        for i in 0..<tableView.numberOfRows {
            let chk = (tableView.view(atColumn: 0, row: i, makeIfNecessary: false)! as! LollyCheckCell).chk!
            chk.state =
                n == 0 ? .on :
                n == 1 ? .off :
                !tableView.selectedRowIndexes.contains(i) ? chk.state :
                n == 2 ? .on : .off
        }
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
