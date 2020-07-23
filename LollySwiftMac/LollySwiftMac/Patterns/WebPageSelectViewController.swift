//
//  PatternsWebPageViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class WebPageSelectViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var vm: PatternsViewModel!
    var vmWebPage: WebPageSelectViewModel!
    var complete: (() -> Void)?
    var arrWebPages: [MWebPage] { vmWebPage.arrWebPages }

    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tvWebPages: NSTableView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        search(self)
    }
    
    @IBAction func search(_ sender: Any) {
        vmWebPage = WebPageSelectViewModel(settings: vm.vmSettings, disposeBag: disposeBag) {
            self.tvWebPages.reloadData()
        }
    }
    
    override func viewDidAppear() {
        view.window?.title = "Existing Page"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        arrWebPages.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        let item = arrWebPages[row]
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tvWebPages.selectedRow
        vmWebPage.selectedWebPage = row == -1 ? nil : arrWebPages[row]
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        self.complete?()
        dismiss(self)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}