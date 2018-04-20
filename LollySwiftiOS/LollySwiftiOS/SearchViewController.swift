//
//  SearchViewController.swift
//  LollySwiftiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit
import WebKit

class SearchViewController: UIViewController, UIWebViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var wvDictOnlineHolder: UIView!
    @IBOutlet weak var wvDictOfflineHolder: UIView!
    weak var wvDictOnline: WKWebView!
    weak var wvDictOffline: WKWebView!

    @IBOutlet weak var sbword: UISearchBar!
    
    var word = ""
    var webViewFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wvDictOnline = addWKWebView(webViewHolder: wvDictOnlineHolder)
        wvDictOffline = addWKWebView(webViewHolder: wvDictOfflineHolder)
        wvDictOnlineHolder.isHidden = true
        wvDictOfflineHolder.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        wvDictOnlineHolder.isHidden = false
        wvDictOfflineHolder.isHidden = true
        
        word = sbword.text!;
        let m = vmSettings.selectedDictOnline
        let url = m.urlString(word)
        webViewFinished = false
        wvDictOnline.load(URLRequest(url: URL(string: url)!))
        sbword.resignFirstResponder()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard webView === wvDictOnline && webView.stringByEvaluatingJavaScript(from: "document.readyState") == "complete" && !webViewFinished else {return}
        
        webViewFinished = true
        let m = vmSettings.selectedDictOnline
        guard m.DICTTYPENAME == "OFFLINE-ONLINE" else {return}
        
        let data = URLCache.shared.cachedResponse(for: webView.request!)!.data;
        let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.loadHTMLString(str, baseURL: URL(string: "/Users/bestskip/Documents/zw/"));
        wvDictOnlineHolder.isHidden = true
        wvDictOfflineHolder.isHidden = false
    }

}
