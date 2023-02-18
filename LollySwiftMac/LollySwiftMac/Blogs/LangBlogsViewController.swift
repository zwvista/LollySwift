//
//  LangBlogsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa

class LangBlogsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, LollyProtocol {

    @IBOutlet weak var tvGroup: NSTableView!
    @IBOutlet weak var tvBlog: NSTableView!

    var vmGroup: BlogGroupsViewModel!
    var vmBlog: LangBlogsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }

    func settingsChanged() {
        vmGroup = BlogGroupsViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            tvGroup.reloadData()
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        vmGroup.arrBlogGroups.count
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
