//
//  PhrasesUnitBatchEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class PhrasesUnitBatchEditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @objc var vm: PhrasesUnitViewModel!
    var complete: (() -> Void)?
    var arrPhrases: [MUnitPhrase] { vm.arrPhrases }

    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    @objc var unitChecked = false
    @objc var partChecked = false
    @objc var seqnumChecked = false
    @objc var unit = 1
    @objc var part = 1
    @objc var seqnum = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = vm.vmSettings.arrUnits
        acParts.content = vm.vmSettings.arrParts
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        view.window?.title = "Batch Edit"
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
    
    @IBAction func checkItems(_ sender: AnyObject) {
        let n = (sender as! NSButton).tag
        for i in 0..<tableView.numberOfRows {
            let chk = (tableView.view(atColumn: 0, row: i, makeIfNecessary: false)! as! LollyCheckCell).chk!
            chk.state =
                n == 0 ? .on :
                n == 1 ? .off :
                !tableView.selectedRowIndexes.contains(i) ? chk.state :
                n == 2 ? .on : .off
        }
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        var o = Observable.just(())
        for i in 0..<tableView.numberOfRows {
            let chk = (tableView.view(atColumn: 0, row: i, makeIfNecessary: false)! as! LollyCheckCell).chk!
            guard chk.state == .on else {continue}
            let item = arrPhrases[i]
            if unitChecked || partChecked || seqnumChecked {
                if unitChecked { item.UNIT = unit }
                if partChecked { item.PART = part }
                if seqnumChecked { item.SEQNUM += seqnum }
                o = o.concat(vm.update(item: item).map {_ in })
            }
        }
        o.subscribe(onNext: {
            self.complete?()
            self.dismiss(sender)
        }) ~ rx.disposeBag
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
