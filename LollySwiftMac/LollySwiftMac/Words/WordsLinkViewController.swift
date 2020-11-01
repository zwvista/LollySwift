//
//  WordsLinkViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/08/04.
//  Copyright © 2019年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class WordsLinkViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    @objc var vm: WordsLangViewModel!
    var vmSettings: SettingsViewModel! { vm.vmSettings }
    var phraseid = 0
    var complete: (() -> Void)?
    var arrWords: [MLangWord] { vm.arrWordsFiltered ?? vm.arrWords }

    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var sfFilter: NSSearchField!
    @objc var textFilter = ""
    @IBOutlet weak var scWordScope: NSSegmentedControl!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reload(self)
    }
    
    @IBAction func reload(_ sender: AnyObject) {
        vm = WordsLangViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.filterWord(self)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        view.window?.title = "Link Word"
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
    
    @IBAction func filterWord(_ sender: AnyObject) {
        let n = scTextFilter.selectedSegment
        vm.applyFilters(textFilter: textFilter, scope: n == 0 ? "Word" : "Note")
        tableView.reloadData()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        guard searchfield === sfFilter else {return}
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        filterWord(self)
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
            let item = arrWords[i]
            if phraseid != 0 {
                o = o.concat(MWordPhrase.link(wordid: item.WORDID, phraseid: phraseid))
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
