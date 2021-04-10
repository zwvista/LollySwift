//
//  WordsAssociateViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/08/04.
//  Copyright © 2019年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class WordsAssociateViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    var vm: WordsLangViewModel!
    var vmSettings: SettingsViewModel! { vm.vmSettings }
    var phraseid = 0
    var textFilter = ""
    var complete: (() -> Void)?
    var arrWords: [MLangWord] { vm.arrWordsFiltered ?? vm.arrWords }

    @IBOutlet weak var scScopeFilter: NSSegmentedControl!
    @IBOutlet weak var sfTextFilter: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    
    func applyFilters() {
        vm.applyFilters()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = WordsLangViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.applyFilters()
        }
        vm.textFilter.accept(textFilter)
        _ = vm.textFilter <~> sfTextFilter.rx.text.orEmpty
        _ = vm.scopeFilter <~> scScopeFilter.rx.selectedLabel
        sfTextFilter.rx.text.subscribe(onNext: { [unowned self] _ in
            self.applyFilters()
        }) ~ rx.disposeBag
        scScopeFilter.rx.selectedLabel.subscribe(onNext: { [unowned self] _ in
            self.applyFilters()
        }) ~ rx.disposeBag
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        view.window?.title = "Associate Word"
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
        guard view.window?.firstResponder != sfTextFilter.window else {return}
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        var o = Observable.just(())
        for i in 0..<tableView.numberOfRows {
            guard let col = tableView.view(atColumn: 0, row: i, makeIfNecessary: false) else {continue}
            guard (col as! LollyCheckCell).chk!.state == .on else {continue}
            let item = arrWords[i]
            if phraseid != 0 {
                o = o.concat(MWordPhrase.associate(wordid: item.WORDID, phraseid: phraseid))
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
