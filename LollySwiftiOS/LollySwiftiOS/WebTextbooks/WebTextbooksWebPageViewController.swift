//
//  WebTextbooksWebPageViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit

class WebTextbooksWebPageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var wvWebPageHolder: UIView!
    @IBOutlet weak var btnWebPage: UIButton!
    weak var wvWebPage: WKWebView!

    var item: MWebTextbook!

    override func viewDidLoad() {
        super.viewDidLoad()
        wvWebPage = addWKWebView(webViewHolder: wvWebPageHolder)
        wvWebPage.navigationDelegate = self
        btnWebPage.setTitle(item.TITLE, for: .normal)
        wvWebPage.load(URLRequest(url: URL(string: item.URL)!))
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
