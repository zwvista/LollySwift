//
//  LangBlogPostsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import Combine
import WebKit

class LangBlogPostsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, LollyProtocol {

    @IBOutlet weak var tvPosts: NSTableView!
    @IBOutlet weak var tvGroups: NSTableView!
    @IBOutlet weak var wvPost: WKWebView!

    var vm: LangBlogPostsViewModel!

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
        vm = LangBlogPostsViewModel(settings: AppDelegate.theSettingsViewModel) { [unowned self] in
            tvPosts.reloadData()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPosts ? vm.arrPosts.count : vm.arrGroups.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView == tvPosts {
            let item = vm.arrPosts[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = vm.arrGroups[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvPosts {
            let i = tvPosts.selectedRow
            vm.selectPost(i == -1 ? nil : vm.arrPosts[i]) { [unowned self] in
                wvPost.loadHTMLString(BlogPostEditViewModel.markedToHtml(text: vm.postContent), baseURL: nil)
                tvGroups.reloadData()
            }
        } else {
            let i = tvGroups.selectedRow
            vm.selectGroup(i == -1 ? nil : vm.arrGroups[i]) { [unowned self] in
            }
        }
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

    @IBAction func addPost(_ sender: Any) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogPostsDetailViewController") as! LangBlogPostsDetailViewController
        detailVC.vmEdit = LangBlogPostsDetailViewModel(vm: vm, item: vm.newPost())
        detailVC.complete = { [unowned self] in tvGroups.reloadData() }
        presentAsModalWindow(detailVC)
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

    @IBAction func selectGroups(_ sender: Any) {
        let i = tvPosts.selectedRow
        if i == -1 {return}
        let selectVC = storyboard!.instantiateController(withIdentifier: "LangBlogSelectGroupsViewController") as! LangBlogSelectGroupsViewController
        selectVC.item = vm.arrPosts[i]
        selectVC.complete = { [unowned self] in
            tvGroups.reloadData()
        }
        presentAsModalWindow(selectVC)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class LangBlogPostsWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
