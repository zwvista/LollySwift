//
//  DictStore.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/08.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import WebKit
import RxBinding

class DictStore: NSObject {
    
    var dictStatus = DictWebViewStatus.ready
    var word = ""
    var dict: MDictionary!
    var url = ""
    
    var vmSettings: SettingsViewModel
    weak var wvDict: WKWebView!
    
    init(settings: SettingsViewModel, wvDict: WKWebView) {
        vmSettings = settings
        self.wvDict = wvDict
    }
    
    func searchDict() async {
        url = dict.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        dictStatus = .ready
        if dict.DICTTYPENAME == "OFFLINE" {
            await wvDict.load(URLRequest(url: URL(string: "about:blank")!))
            let html = await RestApi.getHtml(url: url)
            print(html)
            let str = dict.htmlString(html, word: word)
            await wvDict.loadHTMLString(str, baseURL: nil)
        } else {
            await wvDict.load(URLRequest(url: URL(string: url)!))
            if !dict.AUTOMATION.isEmpty {
                dictStatus = .automating
            } else if dict.DICTTYPENAME == "OFFLINE-ONLINE" {
                dictStatus = .navigating
            }
        }
    }

    func onNavigationFinished() {
        //        guard webView.stringByEvaluatingJavaScript(from: "document.readyState") == "complete" && status == .navigating else {return}
        guard dictStatus != .ready else {return}
        switch dictStatus {
        case .automating:
            let s = dict.AUTOMATION.replacingOccurrences(of: "{0}", with: word)
            wvDict.evaluateJavaScript(s) { (html: Any?, error: Error?) in
                self.dictStatus = .ready
                if self.dict.DICTTYPENAME == "OFFLINE-ONLINE" {
                    self.dictStatus = .navigating
                }
            }
        case .navigating:
            // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
            wvDict.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
                let html = html as! String
                print(html)
                let str = self.dict.htmlString(html, word: self.word)
                self.wvDict.loadHTMLString(str, baseURL: nil)
                self.dictStatus = .ready
            }
        default: break
        }
    }
}
