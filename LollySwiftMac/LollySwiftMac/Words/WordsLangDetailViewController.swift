//
//  WordsLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

@objcMembers
class WordsLangDetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vm: WordsLangViewModel!
    var vmSingle: SingleWordViewModel!
    var complete: (() -> Void)?
    var item: MLangWord!
    var isAdd: Bool!
    var arrWords: [MUnitWord] { vmSingle != nil ? vmSingle.arrWords : [MUnitWord]() }

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfWord: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfFamiID: NSTextField!
    @IBOutlet weak var tfLevel: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
        guard !isAdd else {return}
        vmSingle = SingleWordViewModel(word: item.WORD, settings: vm.vmSettings) {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (item.WORD.isEmpty ? tfWord : tfNote).becomeFirstResponder()
        view.window?.title = isAdd ? "New Word" : item.WORD
    }
    
    @IBAction func clearAccuracy(_ sender: AnyObject) {
        item.CORRECT = 0
        item.TOTAL = 0
        tfAccuracy.stringValue = item.ACCURACY
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        if isAdd {
            vm.arrWords.append(item)
            WordsLangViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }) ~ rx.disposeBag
        } else {
            WordsLangViewModel.update(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        }
        dismiss(sender)
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
