//
//  PhrasesSelectUnitViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/08/04.
//  Copyright © 2019年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class PhrasesSelectUnitViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    @objc var vm: PhrasesUnitViewModel!
    var vmSettings: SettingsViewModel! { vm.vmSettings }
    var wordid = 0
    var patternid = 0
    var complete: (() -> Void)?
    var arrPhrases: [MUnitPhrase] { vm.arrPhrasesFiltered ?? vm.arrPhrases }

    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var sfFilter: NSSearchField!
    @objc var textFilter = ""
    @IBOutlet weak var pubTextbookFilter: NSPopUpButton!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @objc var textbookFilter = 0
    @IBOutlet weak var scPhraseScope: NSSegmentedControl!
    @IBOutlet weak var tableView: NSTableView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        reload(self)
    }
    
    @IBAction func reload(_ sender: AnyObject) {
        vm = PhrasesUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: scPhraseScope.selectedSegment == 0, disposeBag: disposeBag, needCopy: true) {
            self.acTextbooks.content = self.vmSettings.arrTextbookFilters
            self.filterPhrase(self)
        }
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        view.window?.title = "Select Phrase"
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
    
    @IBAction func filterPhrase(_ sender: AnyObject) {
        let n = scTextFilter.selectedSegment
        vm.applyFilters(textFilter: n == 0 ? "" : textFilter, scope: n == 1 ? "Phrase" : "Translation", textbookFilter: textbookFilter)
        tableView.reloadData()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        guard searchfield === sfFilter else {return}
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        if scTextFilter.selectedSegment == 0 {
            scTextFilter.selectedSegment = 1
        }
        filterPhrase(self)
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
        guard view.window?.firstResponder != sfFilter.window else {return}
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        var o = Observable.just(())
        for i in 0..<tableView.numberOfRows {
            guard let col = tableView.view(atColumn: 0, row: i, makeIfNecessary: false) else {continue}
            guard (col as! LollyCheckCell).chk!.state == .on else {continue}
            let item = arrPhrases[i]
            if wordid != 0 {
                o = o.concat(MWordPhrase.connect(wordid: wordid, phraseid: item.PHRASEID))
            } else if patternid != 0 {
                o = o.concat(MPatternPhrase.connect(patternid: patternid, phraseid: item.PHRASEID))
            }
        }
        o.subscribe {
            self.complete?()
            self.dismiss(self)
        }.disposed(by: disposeBag)
    }
}
