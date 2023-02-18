//
//  BlogGroupsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa

class BlogGroupsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfGroupName: NSTextField!

    var vm: BlogGroupsViewModel!
    var complete: (() -> Void)?
    @objc var item: MBlogGroup!
    var isAdd: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
    }
    
}
