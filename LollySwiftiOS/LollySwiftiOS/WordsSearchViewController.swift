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
import NSObject_Rx

class WordsSearchViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate, SettingsViewModelDelegate {
    @IBOutlet weak var wvDictHolder: UIView!
    weak var wvDict: WKWebView!

    @IBOutlet weak var sbword: UISearchBar!
    @IBOutlet weak var btnLang: UIButton!
    @IBOutlet weak var btnDict: UIButton!

    var word = ""
    var status = DictWebViewStatus.ready
    let ddLang = DropDown()
    let ddDictReference = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        wvDict = addWKWebView(webViewHolder: wvDictHolder)
        wvDict.navigationDelegate = self
        vmSettings.delegate = self
        
        vmSettings.getData().subscribe(onNext: {
            self.ddLang.anchorView = self.btnLang
            self.ddLang.selectionAction = { [unowned self] (index: Int, item: String) in
                guard index != vmSettings.selectedLangIndex else {return}
                vmSettings.setSelectedLang(vmSettings.arrLanguages[index]).subscribe() ~ self.rx.disposeBag
            }
            self.ddDictReference.anchorView = self.btnDict
            self.ddDictReference.selectionAction = { [unowned self] (index: Int, item: String) in
                guard index != vmSettings.selectedDictReferenceIndex else {return}
                vmSettings.updateDictReference().subscribe() ~ self.rx.disposeBag
            }
        }) ~ rx.disposeBag
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        word = sbword.text!
        sbword.endEditing(true)
        let item = vmSettings.selectedDictReference!
        let url = item.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        if item.DICTTYPENAME == "OFFLINE" {
            wvDict.load(URLRequest(url: URL(string: "about:blank")!))
            RestApi.getHtml(url: url).subscribe(onNext: { html in
                print(html)
                let str = item.htmlString(html, word: self.word, useTemplate2: true)
                self.wvDict.loadHTMLString(str, baseURL: nil)
            }) ~ rx.disposeBag
        } else {
            wvDict.load(URLRequest(url: URL(string: url)!))
            if item.DICTTYPENAME == "OFFLINE-ONLINE" {
                status = .navigating
            }
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .top
    }
    
    @IBAction func showLangDropDown(_ sender: AnyObject) {
        ddLang.show()
    }

    @IBAction func showDictDropDown(_ sender: AnyObject) {
        ddDictReference.show()
    }
    
    func onGetData() {
        ddLang.dataSource = vmSettings.arrLanguages.map(\.LANGNAME)
    }
    
    func onUpdateLang() {
        let item = vmSettings.selectedLang!
        btnLang.setTitle(item.LANGNAME, for: .normal)
        ddLang.selectIndex(vmSettings.selectedLangIndex)
        
        ddDictReference.dataSource = vmSettings.arrDictsReference.map(\.DICTNAME)
        onUpdateDictReference()
    }
    
    func onUpdateDictReference() {
        let item = vmSettings.selectedDictReference!
        btnDict.setTitle(item.DICTNAME, for: .normal)
        ddDictReference.selectIndex(vmSettings.selectedDictReferenceIndex)
        searchBarSearchButtonClicked(sbword)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        guard webView.stringByEvaluatingJavaScript(from: "document.readyState") == "complete" && status == .navigating else {return}
        guard status == .navigating else {return}
        let item = vmSettings.selectedDictReference!
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
            print(html)
            let str = item.htmlString(html, word: self.word, useTemplate2: true)
            self.wvDict.loadHTMLString(str, baseURL: nil)
            self.status = .ready
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
