//
//  WordsTextbookEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class WordsTextbookEditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vm: WordsUnitViewModel!
    var vmEdit: WordsUnitEditViewModel!
    var itemEdit: MUnitWordEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    @objc var item: MUnitWord!
    var arrWords: [MUnitWord] { vmEdit.vmSingle.arrWords }

    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfTextbookName: NSTextField!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tfWordID: NSTextField!
    @IBOutlet weak var tfWord: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfFamiID: NSTextField!
    @IBOutlet weak var tfLevel: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnOK: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        vmEdit = WordsUnitEditViewModel(vm: vm, item: item) {
            self.tableView.reloadData()
        }
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.TEXTBOOKNAME ~> tfTextbookName.rx.text.orEmpty
        _ = itemEdit.indexUNIT <~> pubUnit.rx.selectedItemIndex
        _ = itemEdit.indexPART <~> pubPart.rx.selectedItemIndex
        _ = itemEdit.SEQNUM <~> tfSeqNum.rx.text.orEmpty
        _ = itemEdit.WORDID ~> tfWordID.rx.text.orEmpty
        _ = itemEdit.WORD <~> tfWord.rx.text.orEmpty
        _ = itemEdit.NOTE <~> tfNote.rx.text
        _ = itemEdit.FAMIID ~> tfFamiID.rx.text.orEmpty
        _ = itemEdit.LEVEL <~> tfLevel.rx.text.orEmpty
        _ = itemEdit.ACCURACY ~> tfAccuracy.rx.text.orEmpty
        btnOK.rx.tap.flatMap { [unowned self] _ in
            self.vmEdit.onOK()
        }.subscribe { [unowned self] _ in
            self.complete?()
            self.dismiss(self.btnOK)
        } ~ rx.disposeBag
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (vmEdit.isAdd ? tfWord : tfNote).becomeFirstResponder()
        view.window?.title = item.WORD
    }
    
    @IBAction func clearAccuracy(_ sender: AnyObject) {
        item.CORRECT = 0
        item.TOTAL = 0
        tfAccuracy.stringValue = item.ACCURACY
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        arrWords.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrWords[row]
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }
    
    // https://stackoverflow.com/questions/10910779/coloring-rows-in-view-based-nstableview
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        let level = arrWords[row].LEVEL
        rowView.backgroundColor = level > 0 ? .yellow : level < 0 ? .gray : .white
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
