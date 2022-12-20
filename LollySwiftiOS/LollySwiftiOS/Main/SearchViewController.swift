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

class SearchViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate, SettingsViewModelDelegate {

    @IBOutlet weak var wvDictHolder: UIView!
    @IBOutlet weak var sbword: UISearchBar!
    @IBOutlet weak var btnLang: UIButton!
    @IBOutlet weak var btnDict: UIButton!

    let dictStore = DictStore()
    let ddLang = DropDown()
    let ddDictReference = DropDown()

    func setup() {
        dictStore.vmSettings = vmSettings
        dictStore.wvDict = addWKWebView(webViewHolder: wvDictHolder)
        dictStore.wvDict.navigationDelegate = self
        vmSettings.delegate = self

        Task {
            await vmSettings.getData()
            ddLang.anchorView = btnLang
            ddLang.selectionAction = { (index: Int, item: String) in
                guard index != vmSettings.selectedLangIndex else {return}
                vmSettings.selectedLangIndex = index
            }
            ddDictReference.anchorView = btnDict
            ddDictReference.selectionAction = { (index: Int, item: String) in
                guard index != vmSettings.selectedDictReferenceIndex else {return}
                vmSettings.selectedDictReferenceIndex = index
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        globalUser.userid = UserDefaults.standard.string(forKey: "userid") ?? ""
        if globalUser.userid.isEmpty {
            logout(self)
        } else {
            setup()
        }
    }

    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "userid")
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            vc.completion = { self.setup() }
            self.present(vc, animated: true)
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
        let item = vmSettings.selectedLang
        btnLang.setTitle(item.LANGNAME, for: .normal)
        ddLang.selectIndex(vmSettings.selectedLangIndex)
        
        ddDictReference.dataSource = vmSettings.arrDictsReference.map(\.DICTNAME)
    }

    func onUpdateDictReference() {
        btnDict.setTitle(vmSettings.selectedDictReference.DICTNAME, for: .normal)
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
