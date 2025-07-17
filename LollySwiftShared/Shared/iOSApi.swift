//
//  iOSApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/02/11.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import WebKit

class iOSApi {
    static func copyText(_ text: String) {
        UIPasteboard.general.string = text
    }

    @MainActor static func googleString(_ str: String) {
        UIApplication.shared.open(URL(string: "https://www.google.com/search?q=\(str.urlEncoded())")!)
    }
}

// https://stackoverflow.com/questions/45998220/the-font-looks-like-smaller-in-wkwebview-than-in-uiwebview
extension WKWebView {

    /// load HTML String same font like the UIWebview
    ///
    //// - Parameters:
    ///   - content: HTML content which we need to load in the webview.
    ///   - baseURL: Content base url. It is optional.
    func loadHTMLStringWithMagic(content:String,baseURL:URL?){
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
        loadHTMLString(headerString + content, baseURL: baseURL)
    }
}
