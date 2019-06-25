//
//  PhrasesLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class PhrasesLangDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vm: PhrasesLangViewModel!
    var vmSingle: SinglePhraseViewModel!
    var complete: (() -> Void)?
    var item: MLangPhrase!
    var isAdd: Bool!
    var arrPhrases: [MUnitPhrase] {
        return vmSingle.arrPhrases
    }

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPhrase: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tableView: NSTableView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
        vmSingle = SinglePhraseViewModel(phrase: item.PHRASE, settings: vm.vmSettings, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (item.PHRASE.isEmpty ? tfPhrase : tfTranslation).becomeFirstResponder()
        view.window?.title = isAdd ? "New Word" : item.PHRASE
    }
    
    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        if isAdd {
            vm.arrPhrases.append(item)
            PhrasesLangViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            PhrasesLangViewModel.update(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrPhrases.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrPhrases[row]
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }
}
