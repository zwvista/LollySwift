//
//  WebPageSelectViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import Combine

@objcMembers
class WebPageSelectViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vm: PatternsViewModel!
    var vmWebPage: WebPageSelectViewModel!
    var complete: (() -> Void)?
    var arrWebPages: [MWebPage] { vmWebPage.arrWebPages }
    var subscriptions = Set<AnyCancellable>()

    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tvWebPages: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        search(self)
    }

    @IBAction func search(_ sender: Any) {
        vmWebPage = WebPageSelectViewModel(settings: vm.vmSettings) {
            self.tvWebPages.reloadData()
        }
        vmWebPage.$title <~> tfTitle.textProperty ~ subscriptions
        vmWebPage.$url <~> tfURL.textProperty ~ subscriptions
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
        self.commitEditing()
        self.complete?()
        dismiss(sender)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
