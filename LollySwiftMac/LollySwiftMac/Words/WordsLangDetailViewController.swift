//
//  WordsLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import Combine

class WordsLangDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfWord: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfFamiID: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnClear: NSButton!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: WordsLangDetailViewModel!
    var item: MLangWord { vmEdit.item }
    var itemEdit: MLangWordEdit { vmEdit.itemEdit }
    var arrWords: [MUnitWord] { vmEdit.vmSingle.arrWords }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        itemEdit.$WORD <~> tfWord.textProperty ~ subscriptions
        itemEdit.$NOTE <~> tfNote.textProperty ~ subscriptions
        tfFamiID.stringValue = itemEdit.FAMIID
        itemEdit.$ACCURACY ~> (tfAccuracy, \.stringValue) ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnOK, \.isEnabled) ~ subscriptions

        vmEdit.vmSingle.$arrWords.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions

        btnClear.tapPublisher.sink { [unowned self] _ in
            vmEdit.itemEdit.clearAccuracy()
        } ~ subscriptions

        btnOK.tapPublisher.sink { [unowned self] in
            Task {
                await vmEdit.onOK()
                complete?()
                dismiss(btnOK)
            }
        } ~ subscriptions
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (vmEdit.isAdd ? tfWord : tfNote).becomeFirstResponder()
        view.window?.title = vmEdit.isAdd ? "New Word" : item.WORD
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
        print("DEBUG: \(className) deinit")
    }
}
