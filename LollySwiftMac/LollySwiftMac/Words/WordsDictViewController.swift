//
//  WordsDictViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/04/02.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import Combine

class WordsDictViewController: NSViewController, WKNavigationDelegate {

    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var tfURL: NSTextField!

    weak var vcWords: WordsPhrasesBaseViewController!

    var word = ""
    var dict: MDictionary!
    var webInitilized = false
    var url: String { dictStore.url }
    let dictStore = DictStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        dictStore.vmSettings = vcWords.vmSettings
        dictStore.wvDict = wvDict
        dictStore.dict = dict
        wvDict.allowsMagnification = true
        wvDict.allowsBackForwardNavigationGestures = true
        webInitilized = true
        load()
    }

    private func load() {
        guard webInitilized else {return}
        dictStore.word = word
        dictStore.searchDict()
    }

    func searchWord(word: String) {
        self.word = word
        load()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Regain focus if it's stolen by the webView
        if vcWords.responder != nil && vcWords.needRegainFocus() {
            Task {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                vcWords?.responder?.window?.makeFirstResponder(vcWords.responder)
                vcWords?.responder = nil
            }
        }
        tfURL.stringValue = webView.url!.absoluteString
        dictStore.onNavigationFinished()
    }

    @IBAction func openURL(_ sender: AnyObject) {
        MacApi.openURL(tfURL.stringValue)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
