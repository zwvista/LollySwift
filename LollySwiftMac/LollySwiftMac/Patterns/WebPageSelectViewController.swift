//
//  WebPageSelectViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

@objcMembers
class WebPageSelectViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tvWebPages: NSTableView!

    var vm: PatternsViewModel!
    var vmWebPage: WebPageSelectViewModel!
    var complete: (() -> Void)?
    var arrWebPages: [MWebPage] { vmWebPage.arrWebPages }

    override func viewDidLoad() {
        super.viewDidLoad()
        search(self)
    }

    @IBAction func search(_ sender: Any) {
        vmWebPage = WebPageSelectViewModel(settings: vm.vmSettings) { [unowned self] in
            tvWebPages.reloadData()
        }
        _ = vmWebPage.title <~> tfTitle.rx.text.orEmpty
        _ = vmWebPage.url <~> tfURL.rx.text.orEmpty
    }

    override func viewDidAppear() {
        super.viewDidAppear()
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
        commitEditing()
        complete?()
        dismiss(sender)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }

}
