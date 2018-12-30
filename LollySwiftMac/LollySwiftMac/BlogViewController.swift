//
//  BlogViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/16.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Cocoa
import WebKit

class BlogViewController: NSViewController {

    @IBOutlet weak var tvMarked: NSTextView!
    @IBOutlet weak var tvHtml: NSTextView!
    @IBOutlet weak var wvBlog: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func markedToHtml(_ sender: Any) {
        tvHtml.string = BlogViewModel.markedToHtml(text: tvMarked.string)
    }
    @IBAction func htmlToMarked(_ sender: Any) {
        tvMarked.string = BlogViewModel.htmlToMarked(text: tvHtml.string)
    }
    
    func replaceSelection(f: (String) -> String) {
        var s = tvMarked.string
        let range = tvMarked.selectedRange()
        s = String(s[Range(range, in: s)!])
        tvMarked.replaceCharacters(in: tvMarked.selectedRange(), with: f(s))
    }

    @IBAction func addTagB(_ sender: Any) {
        return replaceSelection(f: BlogViewModel.addTagB)
    }
    @IBAction func addTagI(_ sender: Any) {
        return replaceSelection(f: BlogViewModel.addTagI)
    }
    @IBAction func removeTags(_ sender: Any) {
        return replaceSelection(f: BlogViewModel.removeTags)
    }
    @IBAction func addExplanation(_ sender: Any) {
        return replaceSelection { _ in BlogViewModel.explanation }
    }

}

class BlogWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
