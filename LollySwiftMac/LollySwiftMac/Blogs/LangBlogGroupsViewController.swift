//
//  LangBlogGroupsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift
import RxBinding

class LangBlogGroupsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, LollyProtocol {

    @IBOutlet weak var tvGroups: NSTableView!
    @IBOutlet weak var tvPosts: NSTableView!
    @IBOutlet weak var wvPost: WKWebView!

    var vm: LangBlogGroupsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        wvPost.allowsMagnification = true
        wvPost.allowsBackForwardNavigationGestures = true
        settingsChanged()
    }

    func settingsChanged() {
        vm = LangBlogGroupsViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            tvGroups.reloadData()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvGroups ? vm.arrGroups.count : vm.arrPosts.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView == tvGroups {
            let item = vm.arrGroups[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = vm.arrPosts[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvGroups {
            let i = tvGroups.selectedRow
            vm.selectGroup(i == -1 ? nil : vm.arrGroups[i]) { [unowned self] in
                tvPosts.reloadData()
            }
        } else {
            let i = tvPosts.selectedRow
            vm.selectPost(i == -1 ? nil : vm.arrPosts[i]) { [unowned self] in
                wvPost.loadHTMLString(BlogEditViewModel.markedToHtml(text: vm.postContent), baseURL: nil)
            }
        }
    }

    @IBAction func addGroup(_ sender: Any) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogGroupsDetailViewController") as! LangBlogGroupsDetailViewController
        detailVC.vmEdit = LangBlogGroupsDetailViewModel(vm: vm, item: vm.newGroup())
        detailVC.complete = { [unowned self] in tvGroups.reloadData() }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editGroup(_ sender: Any) {
        let i = tvGroups.selectedRow
        if i == -1 {return}
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogGroupsDetailViewController") as! LangBlogGroupsDetailViewController
        detailVC.vmEdit = LangBlogGroupsDetailViewModel(vm: vm, item: vm.arrGroups[i])
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
        let itemGroup = vm.arrGroups[i]
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogsDetailViewController") as! LangBlogsDetailViewController
//        let item = vm.newBlog().then {
//            $0.GROUPID = itemGroup.ID
//            $0.GROUPNAME = itemGroup.GROUPNAME
//        }
//        detailVC.vmEdit = LangBlogsDetailViewModel(vm: vm, item: item)
//        detailVC.complete = { [unowned self] in tvGroups.reloadData() }
//        presentAsModalWindow(detailVC)
    }

    @IBAction func editBlog(_ sender: Any) {
        let i = tvPosts.selectedRow
        if i == -1 {return}
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogsDetailViewController") as! LangBlogsDetailViewController
        detailVC.vmEdit = LangBlogsDetailViewModel(vm: vm, item: vm.arrPosts[i])
        detailVC.complete = { [unowned self] in
            tvPosts.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvPosts.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editBlogContent(_ sender: Any) {
        let i = tvPosts.selectedRow
        if i == -1 {return}
        let itemBlog = vm.arrPosts[i]
        MLangBlogPostContent.getDataById(itemBlog.ID).subscribe { [unowned self] in
            (NSApplication.shared.delegate as! AppDelegate).editBlog(settings: vm.vmSettings, item: $0)
        } ~ rx.disposeBag
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class LangBlogGroupsWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
