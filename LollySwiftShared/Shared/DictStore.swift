//
//  DictStore.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/08.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import WebKit

enum DictWebViewStatus {
    case ready
    case navigating
    case automating
}

@MainActor
class DictStore: NSObject, ObservableObject {

    @Published var dictStatus = DictWebViewStatus.ready
    @Published var word = ""
    weak var dict: MDictionary!
    var url = ""

    weak var vmSettings: SettingsViewModel!
    weak var wvDict: WKWebView!

    func searchDict() {
        guard vmSettings != nil else {return}
        url = dict.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        dictStatus = .ready
        if dict.DICTTYPENAME == "OFFLINE" {
            wvDict.load(URLRequest(url: URL(string: "about:blank")!))
            Task {
                let html = await RestApi.getHtml(url: url)
                print(html)
                let str = dict.htmlString(html, word: word)
                wvDict.loadHTMLString(str, baseURL: nil)
            }
        } else {
            wvDict.load(URLRequest(url: URL(string: url)!))
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

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
