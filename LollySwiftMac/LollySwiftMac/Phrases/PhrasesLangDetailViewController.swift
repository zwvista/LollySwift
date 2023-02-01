//
//  PhrasesLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import Combine

class PhrasesLangDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPhrase: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: PhrasesLangDetailViewModel!
    var item: MLangPhrase { vmEdit.item }
    var itemEdit: MLangPhraseEdit { vmEdit.itemEdit }
    var arrPhrases: [MUnitPhrase] { vmEdit.vmSingle.arrPhrases }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        itemEdit.$PHRASE <~> tfPhrase.textProperty ~ subscriptions
        itemEdit.$TRANSLATION <~> tfTranslation.textProperty ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnOK, \.isEnabled) ~ subscriptions

        vmEdit.vmSingle.$arrPhrases.sink { [unowned self] _ in
            tableView.reloadData()
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
        (vmEdit.isAdd ? tfPhrase : tfTranslation).becomeFirstResponder()
        view.window?.title = vmEdit.isAdd ? "New Phrase" : item.PHRASE
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
