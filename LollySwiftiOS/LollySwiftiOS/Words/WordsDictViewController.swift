//
//  WordsDictViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsDictViewController: UIViewController {

    @IBOutlet weak var wvWord: UIWebView!
    var word = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = word
        let m = AppDelegate.theSettingsViewModel.selectedDict
        let url = m.urlString(word)
        wvWord.loadRequest(URLRequest(url: URL(string: url)!))
    }

}