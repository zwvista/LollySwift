//
//  LangBlogGroupsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import Combine
import WebKit

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
        refreshTableView(self)
    }

    @IBAction func refreshTableView(_ sender: Any) {
        vm = LangBlogGroupsViewModel(settings: AppDelegate.theSettingsViewModel) { [unowned self] in
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
                wvPost.loadHTMLString(BlogPostEditViewModel.markedToHtml(text: vm.postContent), baseURL: nil)
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
            editPost(sender)
        }
    }

    @IBAction func editPost(_ sender: Any) {
        let i = tvPosts.selectedRow
        if i == -1 {return}
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogPostsDetailViewController") as! LangBlogPostsDetailViewController
        detailVC.vmEdit = LangBlogPostsDetailViewModel(vm: vm, item: vm.arrPosts[i])
        detailVC.complete = { [unowned self] in
            tvPosts.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvPosts.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editPostContent(_ sender: Any) {
        let i = tvPosts.selectedRow
        if i == -1 {return}
        let itemPost = vm.arrPosts[i]
        Task {
            let item = await MLangBlogPostContent.getDataById(itemPost.ID)
            (NSApplication.shared.delegate as! AppDelegate).editPost(settings: vm.vmSettings, item: item)
        }
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
