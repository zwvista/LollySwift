//
//  EditBlogViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/16.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Cocoa
import WebKit

class EditBlogViewController: NSViewController {

    @IBOutlet weak var tvMarked: NSTextView!
    @IBOutlet weak var tvHtml: NSTextView!
    @IBOutlet weak var wvBlog: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func markedToHtml(_ sender: Any) {
        // let html = markedToHtml(marked: tvMarked.textStorage.)
    }
    @IBAction func htmlToMarked(_ sender: Any) {
        print("bbb")
    }

    func markedToHtml(marked: String) -> String {
        let strs = marked.split("\n")
        return marked
    }
    
    func htmlToMarked(html: String) -> String {
        let strs = html.split("\n")
        return html
    }
}

class EditBlogWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
