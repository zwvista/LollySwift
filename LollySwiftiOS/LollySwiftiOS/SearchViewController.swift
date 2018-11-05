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
    @IBOutlet weak var wvDictHolder: UIView!
    weak var wvDict: WKWebView!

    @IBOutlet weak var sbword: UISearchBar!
    
    var word = ""
    var status: DictWebViewStatus = .ready

    override func viewDidLoad() {
        super.viewDidLoad()
        wvDict = addWKWebView(webViewHolder: wvDictHolder)
        wvDictHolder.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        word = sbword.text!;
        let item = vmSettings.selectedDictOnline
        let url = item.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        wvDict.load(URLRequest(url: URL(string: url)!))
        sbword.resignFirstResponder()
        if item.DICTTYPENAME == "OFFLINE-ONLINE" {
            status = .navigating
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard webView.stringByEvaluatingJavaScript(from: "document.readyState") == "complete" && status == .navigating else {return}
        
        let item = vmSettings.selectedDictOnline
        
        let data = URLCache.shared.cachedResponse(for: webView.request!)!.data;
        let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let str = item.htmlString(html as String, word: word)
        
        wvDict.loadHTMLString(str, baseURL: URL(string: "/Users/bestskip/Documents/zw/"));
        status = .ready
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
