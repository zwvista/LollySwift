//
//  WordsUnitDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class WordsUnitDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vm: WordsUnitViewModel!
    var vmDetail: WordsUnitDetailViewModel!
    var complete: (() -> Void)?
    @objc var item: MUnitWord!
    var arrWords: [MUnitWord] { vmDetail.vmSingle.arrWords }

    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var tfID: NSTextField!
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

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        vmDetail = WordsUnitDetailViewModel(vm: vm, item: item, disposeBag: disposeBag, okComplete: complete) {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (item.WORD.isEmpty ? tfWord : tfNote).becomeFirstResponder()
        view.window?.title = vmDetail.isAdd ? "New Word" : item.WORD
    }
    
    @IBAction func clearAccuracy(_ sender: AnyObject) {
        item.CORRECT = 0
        item.TOTAL = 0
        tfAccuracy.stringValue = item.ACCURACY
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        vmDetail.onOK()
        dismiss(self)
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
