//
//  WordsDictViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import DropDown
import RxSwift

class WordsDictViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var wvDictHolder: UIView!
    @IBOutlet weak var btnWord: UIButton!
    @IBOutlet weak var btnDict: UIButton!
    weak var wvDict: WKWebView!
    
    let vm = SearchViewModel(settings: vmSettings) {}
    let ddWord = DropDown(), ddDictGroup = DropDown()
    
    let disposeBag = DisposeBag()
    var status = DictWebViewStatus.ready

    override func viewDidLoad() {
        super.viewDidLoad()
        wvDict = addWKWebView(webViewHolder: wvDictHolder)
        wvDict.navigationDelegate = self
        
        ddWord.anchorView = btnWord
        ddWord.dataSource = vm.arrWords
        ddWord.selectRow(vm.selectedWordIndex)
        ddWord.selectionAction = { (index: Int, item: String) in
            self.vm.selectedWordIndex = index
            self.selectedWordChanged()
        }
        
        ddDictGroup.anchorView = btnDict
        ddDictGroup.dataSource = vm.vmSettings.arrDictsGroup.map { $0.DICTNAME }
        ddDictGroup.selectRow(vm.vmSettings.selectedDictGroupIndex)
        ddDictGroup.selectionAction = { (index: Int, item: String) in
            self.vm.vmSettings.selectedDictGroupIndex = index
            self.vm.vmSettings.updateDictGroup().subscribe {
                self.selectDictChanged()
            }.disposed(by: self.disposeBag)
        }
        
        selectedWordChanged()
    }
    
    private func selectedWordChanged() {
        btnWord.setTitle(vm.selectedWord, for: .normal)
        navigationItem.title = vm.selectedWord
        selectDictChanged()
    }
    
    private func selectDictChanged() {
        let item = vmSettings.selectedDictGroup
        btnDict.setTitle(item.DICTNAME, for: .normal)
        if item.DICTNAME.starts(with: "Custom") {
            let str = vmSettings.dictHtml(word: vm.selectedWord, dictids: item.dictids())
            wvDict.loadHTMLString(str, baseURL: nil)
        } else {
            let item2 = vmSettings.arrDictsMean.first { $0.DICTNAME == item.DICTNAME }!
            let url = item2.urlString(word: vm.selectedWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
            if item2.DICTTYPENAME == "OFFLINE" {
                wvDict.load(URLRequest(url: URL(string: "about:blank")!))
                RestApi.getHtml(url: url).subscribe(onNext: { html in
                    print(html)
                    let str = item2.htmlString(html, word: self.vm.selectedWord, useTemplate2: true)
                    self.wvDict.loadHTMLString(str, baseURL: nil)
                }).disposed(by: disposeBag)
            } else {
                wvDict.load(URLRequest(url: URL(string: url)!))
                if item2.DICTTYPENAME == "OFFLINE-ONLINE" {
                    status = .navigating
                }
            }
        }
    }
    
    @IBAction func showWordDropDown(_ sender: AnyObject) {
        ddWord.show()
    }
    
    @IBAction func showDictDropDown(_ sender: AnyObject) {
        ddDictGroup.show()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        guard webView.stringByEvaluatingJavaScript(from: "document.readyState") == "complete" && status == .navigating else {return}
        guard status == .navigating else {return}
        let item = vmSettings.selectedDictGroup
        let item2 = vmSettings.arrDictsMean.first { $0.DICTNAME == item.DICTNAME }!
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            let html = html as! String
            print(html)
            let str = item2.htmlString(html, word: self.vm.selectedWord, useTemplate2: true)
            self.wvDict.loadHTMLString(str, baseURL: nil)
            self.status = .ready
        }
    }
}
