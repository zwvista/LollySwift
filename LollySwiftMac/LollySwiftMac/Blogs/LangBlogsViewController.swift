//
//  LangBlogsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class LangBlogsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, LollyProtocol {

    @IBOutlet weak var tvGroups: NSTableView!
    @IBOutlet weak var tvBlogs: NSTableView!

    var vmGroups: LangBlogGroupsViewModel!
    var vmBlogs: LangBlogsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func settingsChanged() {
        vmGroups = LangBlogGroupsViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            tvGroups.reloadData()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvGroups ? vmGroups.arrLangBlogGroups.count : vmBlogs?.arrLangBlogs.count ?? 0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView == tvGroups {
            let item = vmGroups.arrLangBlogGroups[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = vmBlogs.arrLangBlogs[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvGroups {
            let i = tvGroups.selectedRow
            if i == -1 {return}
            let o = vmGroups.arrLangBlogGroups[i]
            vmBlogs = LangBlogsViewModel(settings: vmGroups.vmSettings, needCopy: false, groupId: o.ID) { [unowned self] in
                tvBlogs.reloadData()
            }
        } else {
        }
    }

    @IBAction func addGroup(_ sender: Any) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogGroupsDetailViewController") as! LangBlogGroupsDetailViewController
        detailVC.vmEdit = LangBlogGroupsDetailViewModel(vm: vmGroups, item: vmGroups.newLangBlogGroup())
        detailVC.complete = { [unowned self] in tvGroups.reloadData() }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editGroup(_ sender: Any) {
        let i = tvGroups.selectedRow
        if i == -1 {return}
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogGroupsDetailViewController") as! LangBlogGroupsDetailViewController
        detailVC.vmEdit = LangBlogGroupsDetailViewModel(vm: vmGroups, item: vmGroups.arrLangBlogGroups[i])
        detailVC.complete = { [unowned self] in
            tvGroups.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvGroups.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func doubleAction(_ sender: AnyObject) {
        if sender === tvGroups {
            editGroup(sender)
        } else {
            editBlog(sender)
        }
    }

    @IBAction func addBlog(_ sender: Any) {
        let i = tvGroups.selectedRow
        if i == -1 {return}
        let itemGroup = vmGroups.arrLangBlogGroups[i]
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogsDetailViewController") as! LangBlogsDetailViewController
        let item = vmBlogs.newLangBlog().then {
            $0.GROUPID = itemGroup.ID
            $0.GROUPNAME = itemGroup.GROUPNAME
        }
        detailVC.vmEdit = LangBlogsDetailViewModel(vm: vmBlogs, item: item)
        detailVC.complete = { [unowned self] in tvGroups.reloadData() }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editBlog(_ sender: Any) {
        let i = tvGroups.selectedRow
        if i == -1 {return}
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogsDetailViewController") as! LangBlogsDetailViewController
        detailVC.vmEdit = LangBlogsDetailViewModel(vm: vmBlogs, item: vmBlogs.arrLangBlogs[i])
        detailVC.complete = { [unowned self] in
            tvBlogs.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvBlogs.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editBlogContent(_ sender: Any) {
        let i = tvBlogs.selectedRow
        if i == -1 {return}
        let itemBlog = vmBlogs.arrLangBlogs[i]
        MLangBlogContent.getDataById(itemBlog.ID).subscribe { [unowned self] in
            (NSApplication.shared.delegate as! AppDelegate).editBlog(settings: vmBlogs.vmSettings, item: $0)
        } ~ rx.disposeBag
    }
}

class LangBlogsWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
