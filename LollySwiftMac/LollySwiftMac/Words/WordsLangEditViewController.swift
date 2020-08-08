//
//  WordsLangEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class WordsLangEditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vm: WordsLangViewModel!
    var vmEdit: WordsLangEditViewModel!
    var complete: (() -> Void)?
    @objc var item: MLangWord!
    var arrWords: [MUnitWord] { vmEdit.vmSingle?.arrWords ?? [MUnitWord]() }

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfWord: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfFamiID: NSTextField!
    @IBOutlet weak var tfLevel: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnOK: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = WordsLangEditViewModel(vm: vm, item: item) {
            self.tableView.reloadData()
        }
        _ = vmEdit.itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = vmEdit.itemEdit.WORD <~> tfWord.rx.text.orEmpty
        _ = vmEdit.itemEdit.NOTE <~> tfNote.rx.text
        _ = vmEdit.itemEdit.FAMIID ~> tfFamiID.rx.text.orEmpty
        _ = vmEdit.itemEdit.LEVEL <~> tfLevel.rx.text.orEmpty
        _ = vmEdit.itemEdit.ACCURACY ~> tfAccuracy.rx.text.orEmpty
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
        view.window?.title = vmEdit.isAdd ? "New Word" : item.WORD
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
