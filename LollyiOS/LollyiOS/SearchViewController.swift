//
//  SearchViewController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    let theLollyObject = (UIApplication.sharedApplication().delegate as! AppDelegate).theLollyObject
    
    @IBOutlet var tfWord: UITextField!
    @IBOutlet var wvDictOnline: UIWebView!
    @IBOutlet var wvDictOffline: UIWebView!

    var word = ""
    var webViewFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnMagnifyingGlass = UIButton(type: .Custom)
        let utf8 : [UInt8] = [0xF0, 0x9F, 0x94, 0x8D]
        let str = NSString(bytes: utf8, length: utf8.count, encoding: NSUTF8StringEncoding) as! String
        btnMagnifyingGlass.setTitle(str, forState: UIControlState.Normal)
        btnMagnifyingGlass.sizeToFit()
        btnMagnifyingGlass.addTarget(self, action: "searchDict", forControlEvents: .TouchUpInside);
        
        tfWord.leftView = btnMagnifyingGlass;
        tfWord.leftViewMode = .Always;
        tfWord.autoresizingMask = .FlexibleWidth;
        
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
        
        word = tfWord.text!;
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
        if webView !== wvDictOnline || webView.stringByEvaluatingJavaScriptFromString("document.readyState") != "complete" || webViewFinished {return}
        
        webViewFinished = true
        let m = theLollyObject.currentDict
        if m.DICTTYPENAME != "OFFLINE-ONLINE" {return}
        
        let data = NSURLCache.sharedURLCache().cachedResponseForRequest(webView.request!)!.data;
        let html = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let str = m.htmlString(html as String, word: word)
        
        wvDictOffline.loadHTMLString(str, baseURL: NSURL(string: "/Users/bestskip/Documents/zw/"));
        wvDictOnline.hidden = true
        wvDictOffline.hidden = false
    }

}
