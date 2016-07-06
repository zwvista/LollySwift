//
//  SearchViewController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UIWebViewDelegate, UISearchBarDelegate {    
    @IBOutlet var wvDictOnline: UIWebView!
    @IBOutlet var wvDictOffline: UIWebView!

    @IBOutlet weak var sbword: UISearchBar!
    
    var word = ""
    var webViewFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wvDictOnline.hidden = true
        wvDictOffline.hidden = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        wvDictOnline.hidden = false
        wvDictOffline.hidden = true
        
        word = sbword.text!;
        let m = AppDelegate.theSettingsViewModel.currentDict
        let url = m.urlString(word)
        webViewFinished = false
        wvDictOnline.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        sbword.resignFirstResponder()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView !== wvDictOnline || webView.stringByEvaluatingJavaScriptFromString("document.readyState") != "complete" || webViewFinished {return}
        
        webViewFinished = true
        let m = AppDelegate.theSettingsViewModel.currentDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {return}
        
        let data = NSURLCache.sharedURLCache().cachedResponseForRequest(webView.request!)!.data;
        let html = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.loadHTMLString(str, baseURL: NSURL(string: "/Users/bestskip/Documents/zw/"));
        wvDictOnline.hidden = true
        wvDictOffline.hidden = false
    }

}
