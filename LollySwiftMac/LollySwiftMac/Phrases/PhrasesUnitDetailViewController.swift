//
//  PhrasesUnitDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

@objcMembers
class PhrasesUnitDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vm: PhrasesUnitViewModel!
    var vmDetail: PhrasesUnitDetailViewModel!
    var complete: (() -> Void)?
    var item: MUnitPhrase!
    var arrPhrases: [MUnitPhrase] { vmDetail.vmSingle?.arrPhrases ?? [MUnitPhrase]() }

    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tfPhraseID: NSTextField!
    @IBOutlet weak var tfPhrase: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        vmDetail = PhrasesUnitDetailViewModel(vm: vm, item: item) {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (item.PHRASE.isEmpty ? tfPhrase : tfTranslation).becomeFirstResponder()
        view.window?.title = vmDetail.isAdd ? "New Word" : item.PHRASE
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        vmDetail.onOK().subscribe {
            self.complete?()
            self.dismiss(sender)
        } ~ rx.disposeBag
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
