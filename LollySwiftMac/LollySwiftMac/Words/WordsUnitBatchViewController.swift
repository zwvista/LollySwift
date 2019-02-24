//
//  WordsUnitBatchViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class WordsUnitBatchViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @objc var vm: WordsUnitViewModel!
    var complete: (() -> Void)?
    var arrWords: [MUnitWord] {
        return vm.arrWords
    }

    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tfLevel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    let disposeBag = DisposeBag()
    @objc var unitChecked = false
    @objc var partChecked = false
    @objc var seqnumChecked = false
    @objc var levelChecked = false
    @objc var unit = 1
    @objc var part = 1
    @objc var seqnum = 0
    @objc var level = 0
    @objc var level0Only = true

    override func viewDidLoad() {
        super.viewDidLoad()
        pubUnit.selectItem(at: unit - 1)
        pubPart.selectItem(at: part - 1)
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        view.window?.title = "Batch Edit"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrWords.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrWords[row]
        let columnName = tableColumn!.title
        cell.textField?.stringValue = columnName == "UNIT" ? item.UNITSTR(arrUnits: vm.vmSettings.arrUnits) : columnName == "PART" ? item.PARTSTR(arrParts: vm.vmSettings.arrParts) : String(describing: item.value(forKey: columnName) ?? "")
        return cell;
    }
    
    // https://stackoverflow.com/questions/10910779/coloring-rows-in-view-based-nstableview
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        let level = arrWords[row].LEVEL
        rowView.backgroundColor = level > 0 ? .yellow : level < 0 ? .gray : .white
    }

    @IBAction func unitCheckChanged(_ sender: Any) {
        pubUnit.isEnabled = unitChecked
    }
    @IBAction func partCheckChanged(_ sender: Any) {
        pubPart.isEnabled = partChecked
    }
    @IBAction func seqnumCheckChanged(_ sender: Any) {
        tfSeqNum.isEnabled = seqnumChecked
    }
    @IBAction func levelCheckChanged(_ sender: Any) {
        tfLevel.isEnabled = levelChecked
    }
    
    @IBAction func checkItems(_ sender: Any) {
        let n = (sender as! NSButton).tag
        for i in 0..<tableView.numberOfRows {
            let chk = (tableView.view(atColumn: 0, row: i, makeIfNecessary: false)! as! WordsUnitBatchCell).chk!
            chk.state = n == 0 ? .on : n == 1 ? .off : tableView.selectedRowIndexes.contains(i) ? .on : .off
        }
    }

    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        unit = pubUnit.indexOfSelectedItem + 1
        part = pubPart.indexOfSelectedItem + 1
        var o = Observable.just(())
        for i in 0..<tableView.numberOfRows {
            let chk = (tableView.view(atColumn: 0, row: i, makeIfNecessary: false)! as! WordsUnitBatchCell).chk!
            guard chk.state == .on else {continue}
            let item = arrWords[i]
            if unitChecked || partChecked || seqnumChecked {
                if unitChecked { item.UNIT = unit }
                if partChecked { item.PART = part }
                if seqnumChecked { item.SEQNUM += seqnum }
                o = o.flatMap { MUnitWord.update(item: item) }
            }
            if levelChecked && (!level0Only || item.LEVEL == 0) {
                o = o.flatMap { MWordFami.update(wordid: item.WORDID, level: self.level) }
            }
        }
        o.subscribe {
            self.complete?()
            self.dismiss(self)
        }.disposed(by: disposeBag)
    }
}

class WordsUnitBatchCell: NSTableCellView {
    @IBOutlet weak var chk: NSButton!
}