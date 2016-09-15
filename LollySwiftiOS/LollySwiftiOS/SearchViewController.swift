//
//  SearchViewController.swift
//  LollySwiftiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UIWebViewDelegate, UISearchBarDelegate, LollyProtocol {
    @IBOutlet var wvDictOnline: UIWebView!
    @IBOutlet var wvDictOffline: UIWebView!

    @IBOutlet weak var sbword: UISearchBar!
    
    var word = ""
    var webViewFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wvDictOnline.isHidden = true
        wvDictOffline.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        wvDictOnline.isHidden = false
        wvDictOffline.isHidden = true
        
        word = sbword.text!;
        let m = vmSettings.selectedDict
        let url = m.urlString(word)
        webViewFinished = false
        wvDictOnline.loadRequest(URLRequest(url: URL(string: url)!))
        sbword.resignFirstResponder()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard webView === wvDictOnline && webView.stringByEvaluatingJavaScript(from: "document.readyState") == "complete" && !webViewFinished else {return}
        
        webViewFinished = true
        let m = vmSettings.selectedDict
        guard m.DICTTYPENAME == "OFFLINE-ONLINE" else {return}
        
        let data = URLCache.shared.cachedResponse(for: webView.request!)!.data;
        let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.loadHTMLString(str, baseURL: URL(string: "/Users/bestskip/Documents/zw/"));
        wvDictOnline.isHidden = true
        wvDictOffline.isHidden = false
    }

}
