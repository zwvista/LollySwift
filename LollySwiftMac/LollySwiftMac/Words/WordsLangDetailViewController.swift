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
    @IBOutlet weak var btnOK: NSButton!

    var vm: WordsLangViewModel!
    var complete: (() -> Void)?
    @objc var item: MLangWord!
    var vmEdit: WordsLangDetailViewModel!
    var itemEdit: MLangWordEdit { vmEdit.itemEdit }
    var arrWords: [MUnitWord] { vmEdit.vmSingle?.arrWords ?? [MUnitWord]() }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = WordsLangDetailViewModel(vm: vm, item: item) {
            self.tableView.reloadData()
        }
        itemEdit.$ID ~> (tfID, \.stringValue) ~ subscriptions
        itemEdit.$WORD <~> tfWord.textProperty ~ subscriptions
        itemEdit.$NOTE <~> tfNote.textProperty ~ subscriptions
        itemEdit.$FAMIID ~> (tfFamiID, \.stringValue) ~ subscriptions
        itemEdit.$ACCURACY ~> (tfAccuracy, \.stringValue) ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnOK, \.isEnabled) ~ subscriptions
        btnOK.tapPublisher.sink { [unowned self] in
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
