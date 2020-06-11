//
//  WordsSearchViewController.swift
//  LollySwiftiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import DropDown
import RxSwift

class WordsSearchViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate {
    @IBOutlet weak var wvDictHolder: UIView!
    weak var wvDict: WKWebView!

    @IBOutlet weak var sbword: UISearchBar!
    @IBOutlet weak var btnDict: UIButton!

    var word = ""
    let disposeBag = DisposeBag()
    var status = DictWebViewStatus.ready
    let ddDictReference = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        wvDict = addWKWebView(webViewHolder: wvDictHolder)
        wvDict.navigationDelegate = self
        
        AppDelegate.initializeObject.subscribe {
            self.ddDictReference.anchorView = self.btnDict
            self.ddDictReference.dataSource = vmSettings.arrDictsReference.map { $0.DICTNAME }
            self.ddDictReference.selectRow(vmSettings.selectedDictReferenceIndex)
            self.ddDictReference.selectionAction = { [unowned self] (index: Int, item: String) in
                vmSettings.selectedDictReference = vmSettings.arrDictsReference[index]
                vmSettings.updateDictReference().subscribe {
                    self.searchBarSearchButtonClicked(self.sbword)
                }.disposed(by: self.disposeBag)
            }
            self.searchBarSearchButtonClicked(self.sbword)
        }.disposed(by: disposeBag)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        word = sbword.text!
        sbword.resignFirstResponder()
        let item = vmSettings.selectedDictReference!
        btnDict.setTitle(item.DICTNAME, for: .normal)
        let item2 = vmSettings.arrDictsReference.first { $0.DICTNAME == item.DICTNAME }!
        let url = item2.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        if item2.DICTTYPENAME == "OFFLINE" {
            wvDict.load(URLRequest(url: URL(string: "about:blank")!))
            RestApi.getHtml(url: url).subscribe(onNext: { html in
                print(html)
                let str = item2.htmlString(html, word: self.word, useTemplate2: true)
                self.wvDict.loadHTMLString(str, baseURL: nil)
            }).disposed(by: disposeBag)
        } else {
            wvDict.load(URLRequest(url: URL(string: url)!))
            if item2.DICTTYPENAME == "OFFLINE-ONLINE" {
                status = .navigating
            }
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .top
    }
    
    @IBAction func showDictDropDown(_ sender: AnyObject) {
        ddDictReference.show()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        guard webView.stringByEvaluatingJavaScript(from: "document.readyState") == "complete" && status == .navigating else {return}
        guard status == .navigating else {return}
        let item = vmSettings.selectedDictReference!
        let item2 = vmSettings.arrDictsReference.first { $0.DICTNAME == item.DICTNAME }!
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
            print(html)
            let str = item2.htmlString(html, word: self.word, useTemplate2: true)
            self.wvDict.loadHTMLString(str, baseURL: nil)
            self.status = .ready
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
