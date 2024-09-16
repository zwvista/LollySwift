//
//  BlogPostEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/16.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Cocoa
import WebKit

class BlogPostEditViewController: NSViewController, NSMenuItemValidation  {

    @IBOutlet weak var tvMarked: NSTextView!
    @IBOutlet weak var tvHtml: NSTextView!
    @IBOutlet weak var wvPost: WKWebView!
    @IBOutlet weak var tfTitle: NSTextField!

    var wc: BlogPostEditWindowController { view.window!.windowController as! BlogPostEditWindowController }
    var vm: BlogPostEditViewModel!

    override func viewWillAppear() {
        super.viewWillAppear()
        wvPost.allowsMagnification = true
        wvPost.allowsBackForwardNavigationGestures = true
        tvMarked.font = NSFont.systemFont(ofSize: 16)
        tfTitle.stringValue = vm.title
        Task {
            tvMarked.string = await vm.loadBlog()
            markedToHtml()
        }
    }

    @IBAction func saveMarked(_ sender: AnyObject) {
        Task {
            await vm.saveBlog(content: tvMarked.string)
            markedToHtml()
            MacApi.copyText(tvHtml.string)
        }
    }

    @IBAction func htmlToMarked(_ sender: AnyObject) {
        tvMarked.string = BlogPostEditViewModel.htmlToMarked(text: tvHtml.string)
    }

    func replaceSelection(f: (String) -> String) {
        var s = tvMarked.string
        let range = Range(tvMarked.selectedRange(), in: s)!
        s = String(s[range])
        tvMarked.replaceCharacters(in: tvMarked.selectedRange(), with: f(s))
    }

    @IBAction func addTagB(_ sender: AnyObject) {
        replaceSelection(f: BlogPostEditViewModel.addTagB)
    }
    @IBAction func addTagI(_ sender: AnyObject) {
        replaceSelection(f: BlogPostEditViewModel.addTagI)
    }
    @IBAction func removeTagBI(_ sender: AnyObject) {
        replaceSelection(f: BlogPostEditViewModel.removeTagBI)
    }
    @IBAction func exchangeTagBI(_ sender: AnyObject) {
        replaceSelection(f: BlogPostEditViewModel.exchangeTagBI)
    }
    @IBAction func addExplanation(_ sender: AnyObject) {
        let s = NSPasteboard.general.string(forType: .string) ?? ""
        replaceSelection { _ in BlogPostEditViewModel.getExplanation(text: s) }
        (NSApplication.shared.delegate as! AppDelegate).searchWord(word: s)
    }
    @IBAction func switchPage(_ sender: AnyObject) {
        var n = 0
        if sender is NSMenuItem {
            n = (sender as! NSMenuItem).tag
            wc.scPage.selectedSegment = n
        } else {
            n = (sender as! NSSegmentedControl).selectedSegment
        }
        if n == 0 {
            markedToHtml()
            MacApi.copyText(tvHtml.string)
        } else {
            let url = BlogPostEditViewModel.getPatternUrl(patternNo: wc.patternNo)
            wvPost.load(URLRequest(url: URL(string: url)!))
        }
    }
    func markedToHtml() {
        tvHtml.string = BlogPostEditViewModel.markedToHtml(text: tvMarked.string)
        wvPost.loadHTMLString(tvHtml.string, baseURL: nil)
    }
    @IBAction func openPattern(_ sender: AnyObject) {
        let url = BlogPostEditViewModel.getPatternUrl(patternNo: wc.patternNo)
        MacApi.openURL(url)
    }
    @IBAction func addNotes(_ sender: AnyObject) {
        Task {
            await vm.addNotes(text: tvMarked.string) { [unowned self] in
                tvMarked.string = $0
            }
        }
    }
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(switchPage(_:)) {
            menuItem.state = menuItem.tag == wc.scPage.selectedSegment ? .on : .off
        }
        return true
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class BlogPostEditWindowController: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var scPage: NSSegmentedControl!
    @IBOutlet weak var tfPatternNo: NSTextField!

    @objc var patternNo = "001"

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    func windowWillClose(_ notification: Notification) {
        tfPatternNo.unbindAll()
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
