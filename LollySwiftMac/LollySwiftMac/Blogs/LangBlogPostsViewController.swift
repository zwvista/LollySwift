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
    @IBOutlet weak var sfPostFilter: NSSearchField!
    @IBOutlet weak var sfGroupFilter: NSSearchField!

    let vm = LangBlogPostsViewModel()
    var arrPosts: [MLangBlogPost] { vm.arrPosts }
    var arrGroups: [MLangBlogGroup] { vm.arrGroups }

    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        wvPost.allowsMagnification = true
        wvPost.allowsBackForwardNavigationGestures = true
        vm.$arrPosts.didSet.sink { [unowned self] _ in
            tvPosts.reloadData()
        } ~ subscriptions
        vm.$arrGroups.didSet.sink { [unowned self] _ in
            tvGroups.reloadData()
        } ~ subscriptions
        vm.$postFilter <~> sfPostFilter.textProperty ~ subscriptions
        vm.$groupFilter <~> sfGroupFilter.textProperty ~ subscriptions
        vm.$postHtml.didSet.sink { [unowned self] in
            wvPost.loadHTMLString($0, baseURL: nil)
        } ~ subscriptions
        settingsChanged()
    }

    func settingsChanged() {
        refreshTableView(self)
    }

    @IBAction func refreshTableView(_ sender: Any) {
        Task {
            await vm.reloadPosts()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === tvPosts ? arrPosts.count : arrGroups.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView == tvPosts {
            let item = arrPosts[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = arrGroups[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let tv = notification.object as! NSTableView
        if tv === tvPosts {
            let i = tvPosts.selectedRow
            vm.selectedPost = i == -1 ? nil : arrPosts[i]
        } else {
            let i = tvGroups.selectedRow
            vm.selectedGroup = i == -1 ? nil : arrGroups[i]
        }
    }

    @IBAction func editGroup(_ sender: Any) {
        guard let itemGroup = vm.selectedGroup else {return}
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogGroupsDetailViewController") as! LangBlogGroupsDetailViewController
        detailVC.vmEdit = LangBlogGroupsDetailViewModel(vm: vm, item: itemGroup)
        detailVC.complete = { [unowned self] in
            tvGroups.reloadData(forRowIndexes: [tvGroups.selectedRow], columnIndexes: IndexSet(0..<tvGroups.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func doubleAction(_ sender: AnyObject) {
        if sender === tvGroups {
            editGroup(sender)
        } else if NSApp.currentEvent!.modifierFlags.contains(.option) {
            editPostContent(sender)
        } else {
            editPost(sender)
        }
    }

    @IBAction func addPost(_ sender: Any) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogPostsDetailViewController") as! LangBlogPostsDetailViewController
        detailVC.vmEdit = LangBlogPostsDetailViewModel(vm: vm, itemPost: vm.newPost())
        detailVC.complete = { [unowned self] in tvPosts.reloadData() }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editPost(_ sender: Any) {
        guard let itemPost = vm.selectedPost else {return}
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogPostsDetailViewController") as! LangBlogPostsDetailViewController
        detailVC.vmEdit = LangBlogPostsDetailViewModel(vm: vm, itemPost: itemPost)
        detailVC.complete = { [unowned self] in
            tvPosts.reloadData(forRowIndexes: [tvPosts.selectedRow], columnIndexes: IndexSet(0..<tvPosts.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editPostContent(_ sender: Any) {
        guard let itemPost = vm.selectedPost else {return}
        Task {
            let item = await MLangBlogPostContent.getDataById(itemPost.ID)
            (NSApplication.shared.delegate as! AppDelegate).editPost(item: item)
        }
    }

    @IBAction func selectGroups(_ sender: Any) {
        let i = tvPosts.selectedRow
        if i == -1 {return}
        let selectVC = storyboard!.instantiateController(withIdentifier: "LangBlogSelectGroupsViewController") as! LangBlogSelectGroupsViewController
        selectVC.item = arrPosts[i]
        selectVC.complete = { [unowned self] in tvPosts.reloadData() }
        presentAsModalWindow(selectVC)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
