//
//  WordsDictViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/04/02.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift
import NSObject_Rx

class WordsDictViewController: NSViewController, WKNavigationDelegate {

    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var tfURL: NSTextField!
    weak var vcWords: WordsBaseViewController!

    var dictStatus = DictWebViewStatus.ready
    var word = ""
    var dict: MDictionary!
    var webInitilized = false
    var url = ""
    var subscription: Disposable? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        wvDict.allowsMagnification = true
        wvDict.allowsBackForwardNavigationGestures = true
        webInitilized = true
        load()
    }
    
    private func load() {
        guard webInitilized, !url.isEmpty else {return}
        if dict.DICTTYPENAME == "OFFLINE" {
            wvDict.load(URLRequest(url: URL(string: "about:blank")!))
            RestApi.getHtml(url: url).subscribe(onNext: { html in
                print(html)
                let str = self.dict.htmlString(html, word: self.word)
                self.wvDict.loadHTMLString(str, baseURL: nil)
            }) ~ rx.disposeBag
        } else {
            wvDict.load(URLRequest(url: URL(string: url)!))
            if dict.AUTOMATION != nil {
                dictStatus = .automating
            } else if dict.DICTTYPENAME == "OFFLINE-ONLINE" {
                dictStatus = .navigating
            }
        }
    }
    
    func searchWord(word: String) {
        self.word = word
        dictStatus = .ready
        url = dict.urlString(word: word, arrAutoCorrect: vcWords.vmSettings.arrAutoCorrect)
        load()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Regain focus if it's stolen by the webView
        if vcWords.responder != nil && vcWords.needRegainFocus() {
            subscription?.dispose()
            subscription = Observable<Int>.timer(DispatchTimeInterval.milliseconds(500), period: DispatchTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance).subscribe { _ in
                self.subscription?.dispose()
                self.vcWords?.responder?.window!.makeFirstResponder(self.vcWords.responder)
                self.vcWords?.responder = nil
            }
            subscription?.disposed(by: self.rx.disposeBag)
        }
        tfURL.stringValue = webView.url!.absoluteString
        guard dictStatus != .ready else {return}
        switch dictStatus {
        case .automating:
            let s = dict.AUTOMATION!.replacingOccurrences(of: "{0}", with: word)
            webView.evaluateJavaScript(s) { (html: Any?, error: Error?) in
                self.dictStatus = .ready
                if self.dict.DICTTYPENAME == "OFFLINE-ONLINE" {
                    self.dictStatus = .navigating
                }
            }
        case .navigating:
            // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
                let html = html as! String
                print(html)
                let str = self.dict.htmlString(html, word: self.word)
                self.wvDict.loadHTMLString(str, baseURL: nil)
                self.dictStatus = .ready
            }
        default: break
        }
    }
    
    @IBAction func openURL(_ sender: AnyObject) {
        MacApi.openURL(tfURL.stringValue)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
