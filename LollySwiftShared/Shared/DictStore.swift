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

enum DictWebViewStatus {
    case ready
    case navigating
    case automating
}

class DictStore: NSObject {

    var dictStatus = DictWebViewStatus.ready
    var word = ""
    var dict: MDictionary!
    var url = ""

    var vmSettings: SettingsViewModel
    weak var wvDict: WKWebView!

    init(vmSettings: SettingsViewModel, wvDict: WKWebView) {
        self.vmSettings = vmSettings
        self.wvDict = wvDict
    }

    func searchDict() {
        url = dict.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        dictStatus = .ready
        if dict.DICTTYPENAME == "OFFLINE" {
            wvDict.load(URLRequest(url: URL(string: "about:blank")!))
            RestApi.getHtml(url: url).subscribe { [unowned self] html in
                print(html)
                let str = dict.htmlString(html, word: word)
                wvDict.loadHTMLString(str, baseURL: nil)
            } ~ rx.disposeBag
        } else {
            // https://stackoverflow.com/questions/74120763/in-webview-leads-to-crash-and-ui-unresponsiveness
            DispatchQueue.main.async { [unowned self] in
                wvDict.load(URLRequest(url: URL(string: url)!))
            }
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
            wvDict.evaluateJavaScript(s) { [unowned self] (html: Any?, error: Error?) in
                dictStatus = .ready
                if dict.DICTTYPENAME == "OFFLINE-ONLINE" {
                    dictStatus = .navigating
                }
            }
        case .navigating:
            // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
            wvDict.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [unowned self] (html: Any?, error: Error?) in
                let html = html as! String
                print(html)
                let str = dict.htmlString(html, word: word)
                wvDict.loadHTMLString(str, baseURL: nil)
                dictStatus = .ready
            }
        default: break
        }
    }
}
