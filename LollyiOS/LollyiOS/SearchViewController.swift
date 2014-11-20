//
//  SearchViewController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    var theLollyObject = (UIApplication.sharedApplication().delegate as AppDelegate).theLollyObject
    
    @IBOutlet var tfWord: UITextField!
    @IBOutlet var wvDictOnline: UIWebView!
    @IBOutlet var wvDictOffline: UIWebView!

    var word = ""
    var webViewFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var btnMagnifyingGlass = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        btnMagnifyingGlass.setTitle("\u{F09F}\u{948D}", forState: UIControlState.Normal)
        btnMagnifyingGlass.sizeToFit()
        btnMagnifyingGlass.addTarget(self, action: "searchDict", forControlEvents: UIControlEvents.TouchUpInside);
        
        tfWord.leftView = btnMagnifyingGlass;
        tfWord.leftViewMode = UITextFieldViewMode.Always;
        tfWord.autoresizingMask = UIViewAutoresizing.FlexibleWidth;
        
        wvDictOnline.hidden = true
        wvDictOffline.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchDict(sender: AnyObject) {
        wvDictOnline.hidden = false
        wvDictOffline.hidden = true
        
        word = tfWord.text;
        let m = theLollyObject.currentDict
        let url = m.urlString(word)
        webViewFinished = false
        wvDictOnline.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        tfWord.resignFirstResponder()
    }
        
    @IBAction func tfWordDismiss(sender: AnyObject) {
        searchDict(sender)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView.scrollView.contentInset.bottom == 0 {
            webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(tabBarController!.tabBar.frame), 0);
        }
        
        if webView !== wvDictOnline || webView.stringByEvaluatingJavaScriptFromString("document.readyState") != "complete" || webViewFinished {return}
        
        webViewFinished = true
        let m = theLollyObject.currentDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {return}
        
        let data = NSURLCache.sharedURLCache().cachedResponseForRequest(webView.request!)!.data;
        let html = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let str = m.htmlString(html, word: word)
        
        wvDictOffline.loadHTMLString(str, baseURL: NSURL(string: "/Users/bestskip/Documents/zw/"));
        wvDictOnline.hidden = true
        wvDictOffline.hidden = false
    }

}
