//
//  WordsDictViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit

class WordsDictViewController: UIViewController {

    @IBOutlet weak var wvWordHolder: UIView!
    weak var wvWord: WKWebView!
    var word = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        wvWord = addWKWebView(webViewHolder: wvWordHolder)
        navigationItem.title = word
        let m = vmSettings.selectedDict
        let url = m.urlString(word)
        wvWord.load(URLRequest(url: URL(string: url)!))
    }

}
