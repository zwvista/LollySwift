//
//  DictWebView.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/08.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import WebKit

class DictWebView: WKWebView, WKNavigationDelegate {
    
    var dictStatus = DictWebViewStatus.ready
    var word = ""
    var dict: MDictionary!
    var urlString = ""
    
    func SearchDict() {
        if dict.DICTTYPENAME == "OFFLINE" {
            load(URLRequest(url: URL(string: "about:blank")!))
            RestApi.getHtml(url: urlString).subscribe(onNext: { html in
                print(html)
                let str = self.dict.htmlString(html, word: self.word)
                self.loadHTMLString(str, baseURL: nil)
            }) ~ rx.disposeBag
        } else {
            load(URLRequest(url: URL(string: urlString)!))
            if !dict.AUTOMATION.isEmpty {
                dictStatus = .automating
            } else if dict.DICTTYPENAME == "OFFLINE-ONLINE" {
                dictStatus = .navigating
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard dictStatus != .ready else {return}
        switch dictStatus {
        case .automating:
            let s = dict.AUTOMATION.replacingOccurrences(of: "{0}", with: word)
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
                self.loadHTMLString(str, baseURL: nil)
                self.dictStatus = .ready
            }
        default: break
        }
    }
}
