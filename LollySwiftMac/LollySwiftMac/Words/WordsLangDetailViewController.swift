//
//  WordsLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class WordsLangDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfWord: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfFamiID: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: WordsLangDetailViewModel!
    var item: MLangWord { vmEdit.item }
    var itemEdit: MLangWordEdit { vmEdit.itemEdit }
    var arrWords: [MUnitWord] { vmEdit.vmSingle?.arrWords ?? [MUnitWord]() }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        _ = itemEdit.WORD <~> tfWord.rx.text.orEmpty
        _ = itemEdit.NOTE <~> tfNote.rx.text.orEmpty
        tfFamiID.stringValue = itemEdit.FAMIID
        _ = itemEdit.ACCURACY ~> tfAccuracy.rx.text.orEmpty
        _ = vmEdit.isOKEnabled ~> btnOK.rx.isEnabled
        btnOK.rx.tap.flatMap { [unowned self] in
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

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
