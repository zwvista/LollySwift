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
    weak var vcWords: WordsPhrasesBaseViewController!

    var word = ""
    var dict: MDictionary!
    var webInitilized = false
    var url: String { dictStore.url }
    var subscription: Disposable? = nil
    var dictStore: DictStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        dictStore = DictStore(settings: vcWords.vmSettings, wvDict: wvDict)
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
            subscription?.dispose()
            subscription = Observable<Int>.timer(DispatchTimeInterval.milliseconds(500), period: DispatchTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance).subscribe { _ in
                self.subscription?.dispose()
                self.vcWords?.responder?.window!.makeFirstResponder(self.vcWords.responder)
                self.vcWords?.responder = nil
            }
            subscription?.disposed(by: self.rx.disposeBag)
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
