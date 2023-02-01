//
//  BlogViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/16.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Cocoa
import WebKit

class BlogViewController: NSViewController, NSMenuItemValidation  {

    @IBOutlet weak var tvMarked: NSTextView!
    @IBOutlet weak var tvHtml: NSTextView!
    @IBOutlet weak var wvBlog: WKWebView!
    @IBOutlet weak var tfStatusText: NSTextField!

    var vm: SettingsViewModel { AppDelegate.theSettingsViewModel }
    var wc: BlogWindowController { view.window!.windowController as! BlogWindowController }
    var vmBlog: BlogViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        vmBlog = BlogViewModel(settings: vm)
        tvMarked.font = NSFont.systemFont(ofSize: 15)
        updateStatusText()
        Task {
            tvMarked.string = await vm.getBlogContent()
        }
    }

    @IBAction func saveMarked(_ sender: AnyObject) {
        Task {
            await vm.saveBlogContent(content: tvMarked.string)
        }
    }

    @IBAction func htmlToMarked(_ sender: AnyObject) {
        tvMarked.string = vmBlog.htmlToMarked(text: tvHtml.string)
    }

    func replaceSelection(f: (String) -> String) {
        var s = tvMarked.string
        let range = Range(tvMarked.selectedRange(), in: s)!
        s = String(s[range])
        tvMarked.replaceCharacters(in: tvMarked.selectedRange(), with: f(s))
    }

    @IBAction func addTagB(_ sender: AnyObject) {
        replaceSelection(f: vmBlog.addTagB)
    }
    @IBAction func addTagI(_ sender: AnyObject) {
        replaceSelection(f: vmBlog.addTagI)
    }
    @IBAction func removeTagBI(_ sender: AnyObject) {
        replaceSelection(f: vmBlog.removeTagBI)
    }
    @IBAction func exchangeTagBI(_ sender: AnyObject) {
        replaceSelection(f: vmBlog.exchangeTagBI)
    }
    @IBAction func addExplanation(_ sender: AnyObject) {
        let s = NSPasteboard.general.string(forType: .string) ?? ""
        replaceSelection { _ in vmBlog.getExplanation(text: s) }
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
            tvHtml.string = vmBlog.markedToHtml(text: tvMarked.string)
            let str = CommonApi.toHtml(text: tvHtml.string)
            wvBlog.loadHTMLString(str, baseURL: nil)
            MacApi.copyText(tvHtml.string)
        } else {
            let url = vmBlog.getPatternUrl(patternNo: wc.patternNo)
            wvBlog.load(URLRequest(url: URL(string: url)!))
        }
    }
    @IBAction func openPattern(_ sender: AnyObject) {
        let url = vmBlog.getPatternUrl(patternNo: wc.patternNo)
        MacApi.openURL(url)
    }
    @IBAction func addNotes(_ sender: AnyObject) {
        Task {
            await vmBlog.addNotes(text: tvMarked.string) { [unowned self] in
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

    func updateStatusText() {
        tfStatusText.stringValue = vm.UNITINFO
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class BlogWindowController: NSWindowController, NSWindowDelegate {
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
