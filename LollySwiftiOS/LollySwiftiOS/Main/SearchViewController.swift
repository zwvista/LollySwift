//
//  SearchViewController.swift
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

class SearchViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate, SettingsViewModelDelegate {
    @IBOutlet weak var wvDictHolder: UIView!
    var dictStore: DictStore!

    @IBOutlet weak var sbword: UISearchBar!
    @IBOutlet weak var btnLang: UIButton!
    @IBOutlet weak var btnDict: UIButton!

    let ddLang = DropDown()
    let ddDictReference = DropDown()
    
    func setup() {
        dictStore = DictStore(settings: vmSettings, wvDict: addWKWebView(webViewHolder: wvDictHolder))
        dictStore.wvDict.navigationDelegate = self
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
                vmSettings.selectedDictReference = vmSettings.arrDictsReference[index]
                vmSettings.updateDictReference().subscribe() ~ self.rx.disposeBag
            }
        }) ~ rx.disposeBag
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CommonApi.userid = UserDefaults.standard.integer(forKey: "userid")
        if CommonApi.userid == 0 {
            logout(self)
        } else {
            setup()
        }
    }

    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "userid")
        if let vc = self.storyboard?.instantiateVC(LoginViewController.self) {
            vc.completion = { self.setup() }
            self.present(vc, animated: true) {}
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        sbword.endEditing(true)
        dictStore.word = sbword.text!
        dictStore.searchDict()
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
        btnDict.setTitle(vmSettings.selectedDictReference!.DICTNAME, for: .normal)
        ddDictReference.selectIndex(vmSettings.selectedDictReferenceIndex)
        dictStore.dict = vmSettings.selectedDictReference
        dictStore.searchDict()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dictStore.onNavigationFinished()
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}