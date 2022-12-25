//
//  SearchViewController.swift
//  LollySwiftiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit
import WebKit

class SearchViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate, SettingsViewModelDelegate {

    @IBOutlet weak var wvDictHolder: UIView!
    @IBOutlet weak var sbword: UISearchBar!
    @IBOutlet weak var btnLang: UIButton!
    @IBOutlet weak var btnDict: UIButton!

    let dictStore = DictStore()

    func setup() {
        dictStore.vmSettings = vmSettings
        dictStore.wvDict = addWKWebView(webViewHolder: wvDictHolder)
        dictStore.wvDict.navigationDelegate = self
        vmSettings.delegate = self

        Task {
            await vmSettings.getData()
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

    func onGetData() {
        func configMenuLang() {
            btnLang.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrLanguages.map(\.LANGNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vmSettings.selectedLangIndex ? .on : .off) { _ in
                    guard index != vmSettings.selectedLangIndex else {return}
                    vmSettings.selectedLangIndex = index
                    configMenuLang()
                }
            })
            btnLang.showsMenuAsPrimaryAction = true
        }
        configMenuLang()
    }

    func onUpdateLang() {
        let item = vmSettings.selectedLang
        btnLang.setTitle(item.LANGNAME, for: .normal)
    }

    func onUpdateDictReference() {
        btnDict.setTitle(vmSettings.selectedDictReference.DICTNAME, for: .normal)

        func configMenuDict() {
            btnDict.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrDictsReference.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vmSettings.selectedDictReferenceIndex ? .on : .off) { _ in
                    guard index != vmSettings.selectedDictReferenceIndex else {return}
                    vmSettings.selectedDictReferenceIndex = index
                    configMenuDict()
                }
            })
            btnDict.showsMenuAsPrimaryAction = true
        }
        configMenuDict()

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
