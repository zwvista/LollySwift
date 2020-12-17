//
//  PhrasesLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class PhrasesLangDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vm: PhrasesLangViewModel!
    var complete: (() -> Void)?
    var item: MLangPhrase!
    var vmEdit: PhrasesLangDetailViewModel!
    var itemEdit: MLangPhraseEdit { vmEdit.itemEdit }
    var arrPhrases: [MUnitPhrase] { vmEdit.vmSingle?.arrPhrases ?? [MUnitPhrase]() }

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPhrase: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnOK: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = PhrasesLangDetailViewModel(vm: vm, item: item) {
            self.tableView.reloadData()
        }
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.PHRASE <~> tfPhrase.rx.text.orEmpty
        _ = itemEdit.TRANSLATION <~> tfTranslation.rx.text.orEmpty
        _ = vmEdit.isOKEnabled ~> btnOK.rx.isEnabled
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
        print("DEBUG: \(self.className) deinit")
    }
}
