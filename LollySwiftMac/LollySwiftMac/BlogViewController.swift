//
//  BlogViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/16.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class BlogViewController: NSViewController  {

    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }
    @IBOutlet weak var tvMarked: NSTextView!
    @IBOutlet weak var tvHtml: NSTextView!
    @IBOutlet weak var wvBlog: WKWebView!
    
    var wc: BlogWindowController { return view.window!.windowController as! BlogWindowController }
    var vmBlog: BlogViewModel!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        vmBlog = BlogViewModel(settings: vm, disposeBag: disposeBag)
    }

    @IBAction func htmlToMarked(_ sender: Any) {
        tvMarked.string = vmBlog.htmlToMarked(text: tvHtml.string)
    }
    
    func replaceSelection(f: (String) -> String) {
        var s = tvMarked.string
        let range = tvMarked.selectedRange()
        s = String(s[Range(range, in: s)!])
        tvMarked.replaceCharacters(in: tvMarked.selectedRange(), with: f(s))
    }

    @IBAction func addTagB(_ sender: Any) {
        return replaceSelection(f: vmBlog.addTagB)
    }
    @IBAction func addTagI(_ sender: Any) {
        return replaceSelection(f: vmBlog.addTagI)
    }
    @IBAction func removeTagBI(_ sender: Any) {
        return replaceSelection(f: vmBlog.removeTagBI)
    }
    @IBAction func exchangeTagBI(_ sender: Any) {
        return replaceSelection(f: vmBlog.exchangeTagBI)
    }
    @IBAction func addExplanation(_ sender: Any) {
        return replaceSelection { _ in vmBlog.explanation }
    }
    @IBAction func switchPage(_ sender: Any) {
        let n = (sender as? NSMenuItem)?.tag ?? (sender as! NSControl).tag
        if n == 0 {
            tvHtml.string = vmBlog.markedToHtml(text: tvMarked.string)
            let str = vmBlog.getHtml(text: tvHtml.string)
            wvBlog.loadHTMLString(str, baseURL: nil)
            MacApi.copyText(tvHtml.string)
        } else {
            let url = vmBlog.getPatternUrl(patternNo: wc.patternNo)
            wvBlog.load(URLRequest(url: URL(string: url)!))
        }
    }
    @IBAction func copyPatternMarkDown(_ sender: Any) {
        let text = vmBlog.getPatternMarkDown(patternText: wc.patternText)
        MacApi.copyText(text)
    }
    @IBAction func addNotes(_ sender: Any) {
        vmBlog.addNotes(text: tvMarked.string) {
            self.tvMarked.string = $0
        }
    }
}

class BlogWindowController: NSWindowController, NSTextFieldDelegate {
    @IBOutlet weak var scPage: NSSegmentedControl!
    @IBOutlet weak var tfPatternNo: NSTextField!
    @IBOutlet weak var tfPatternText: NSTextField!
    
    @objc var patternNo = "001"
    @objc var patternText = ""

    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
