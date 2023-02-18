//
//  LangBlogsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa

class LangBlogsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, LollyProtocol {

    @IBOutlet weak var tvGroups: NSTableView!
    @IBOutlet weak var tvBlogs: NSTableView!

    var vmGroup: LangBlogGroupsViewModel!
    var vmBlog: LangBlogsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func settingsChanged() {
        vmGroup = LangBlogGroupsViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            tvGroups.reloadData()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        vmGroup.arrLangBlogGroups.count
    }

    @IBAction func addGroup(_ sender: Any) {
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogGroupsDetailViewController") as! LangBlogGroupsDetailViewController
        detailVC.vmEdit = LangBlogGroupsDetailViewModel(vm: vmGroup, item: vmGroup.newLangBlogGroup())
        detailVC.complete = { [unowned self] in tvGroups.reloadData() }
        presentAsModalWindow(detailVC)
    }

    @IBAction func editGroup(_ sender: Any) {
        let i = tvGroups.selectedRow
        if i == -1 {return}
        let detailVC = storyboard!.instantiateController(withIdentifier: "LangBlogGroupsDetailViewController") as! LangBlogGroupsDetailViewController
        detailVC.vmEdit = LangBlogGroupsDetailViewModel(vm: vmGroup, item: vmGroup.arrLangBlogGroups[i])
        detailVC.complete = { [unowned self] in
            tvGroups.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<tvGroups.tableColumns.count))
        }
        presentAsModalWindow(detailVC)
    }

    @IBAction func addBlog(_ sender: Any) {
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
