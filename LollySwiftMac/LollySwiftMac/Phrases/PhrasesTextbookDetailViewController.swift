//
//  PhrasesTextbookDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import Combine

class PhrasesTextbookDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfTextbookName: NSTextField!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tfPhraseID: NSTextField!
    @IBOutlet weak var tfPhrase: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: PhrasesUnitDetailViewModel!
    var item: MUnitPhrase { vmEdit.item }
    var itemEdit: MUnitPhraseEdit { vmEdit.itemEdit }
    var arrPhrases: [MUnitPhrase] { vmEdit.vmSingle.arrPhrases }
    var subscriptions = Set<AnyCancellable>()

    func startEdit(vm: PhrasesUnitViewModel, item: MUnitPhrase) {
        vmEdit = PhrasesUnitDetailViewModel(vm: vm, item: item, wordid: 0) {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        itemEdit.$ID ~> (tfID, \.stringValue) ~ subscriptions
        itemEdit.$TEXTBOOKNAME ~> (tfTextbookName, \.stringValue) ~ subscriptions
        itemEdit.$indexUNIT <~> pubUnit.selectedItemIndexProperty ~ subscriptions
        itemEdit.$indexPART <~> pubPart.selectedItemIndexProperty ~ subscriptions
        itemEdit.$SEQNUM <~> tfSeqNum.textProperty ~ subscriptions
        itemEdit.$PHRASEID ~> (tfPhraseID, \.stringValue) ~ subscriptions
        itemEdit.$PHRASE <~> tfPhrase.textProperty ~ subscriptions
        itemEdit.$TRANSLATION <~> tfTranslation.textProperty ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnOK, \.isEnabled) ~ subscriptions
        btnOK.tapPublisher.sink {
            Task {
                await self.vmEdit.onOK()
                self.complete?()
                self.dismiss(self.btnOK)
            }
        } ~ subscriptions
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (vmEdit.isAdd ? tfPhrase : tfTranslation).becomeFirstResponder()
        view.window?.title = item.PHRASE
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
        print("DEBUG: \(self.className) deinit")
    }
}
