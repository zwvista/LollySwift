//
//  BlogEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/16.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift
import RxBinding

class BlogEditViewController: NSViewController, NSMenuItemValidation  {

    @IBOutlet weak var tvMarked: NSTextView!
    @IBOutlet weak var tvHtml: NSTextView!
    @IBOutlet weak var wvBlog: WKWebView!
    @IBOutlet weak var tfTitle: NSTextField!

    var wc: BlogEditWindowController { view.window!.windowController as! BlogEditWindowController }
    var vm: BlogEditViewModel!

    override func viewWillAppear() {
        super.viewWillAppear()
        tvMarked.font = NSFont.systemFont(ofSize: 16)
        tfTitle.stringValue = vm.title
        vm.loadBlog { [unowned self] in
            tvMarked.string = $0
        }
    }

    @IBAction func saveMarked(_ sender: AnyObject) {
        vm.saveBlog(content: tvMarked.string)
    }

    @IBAction func htmlToMarked(_ sender: AnyObject) {
        tvMarked.string = BlogEditViewModel.htmlToMarked(text: tvHtml.string)
    }

    func replaceSelection(f: (String) -> String) {
        var s = tvMarked.string
        let range = Range(tvMarked.selectedRange(), in: s)!
        s = String(s[range])
        tvMarked.replaceCharacters(in: tvMarked.selectedRange(), with: f(s))
    }

    @IBAction func addTagB(_ sender: AnyObject) {
        replaceSelection(f: BlogEditViewModel.addTagB)
    }
    @IBAction func addTagI(_ sender: AnyObject) {
        replaceSelection(f: BlogEditViewModel.addTagI)
    }
    @IBAction func removeTagBI(_ sender: AnyObject) {
        replaceSelection(f: BlogEditViewModel.removeTagBI)
    }
    @IBAction func exchangeTagBI(_ sender: AnyObject) {
        replaceSelection(f: BlogEditViewModel.exchangeTagBI)
    }
    @IBAction func addExplanation(_ sender: AnyObject) {
        let s = NSPasteboard.general.string(forType: .string) ?? ""
        replaceSelection { _ in BlogEditViewModel.getExplanation(text: s) }
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
            tvHtml.string = BlogEditViewModel.markedToHtml(text: tvMarked.string)
            let str = CommonApi.toHtml(text: tvHtml.string)
            wvBlog.loadHTMLString(str, baseURL: nil)
            MacApi.copyText(tvHtml.string)
        } else {
            let url = BlogEditViewModel.getPatternUrl(patternNo: wc.patternNo)
            wvBlog.load(URLRequest(url: URL(string: url)!))
        }
    }
    @IBAction func openPattern(_ sender: AnyObject) {
        let url = BlogEditViewModel.getPatternUrl(patternNo: wc.patternNo)
        MacApi.openURL(url)
    }
    @IBAction func addNotes(_ sender: AnyObject) {
        vm.addNotes(text: tvMarked.string) { [unowned self] in
            tvMarked.string = $0
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

class BlogEditWindowController: NSWindowController, NSWindowDelegate {
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
