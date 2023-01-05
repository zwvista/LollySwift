//
//  SearchViewController.swift
//  LollySwiftiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import Combine

class SearchViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate {

    @IBOutlet weak var wvDictHolder: UIView!
    @IBOutlet weak var sbword: UISearchBar!
    @IBOutlet weak var btnLang: UIButton!
    @IBOutlet weak var btnDict: UIButton!

    let dictStore = DictStore()
    var subscriptions = Set<AnyCancellable>()

    func setup() {
        dictStore.vmSettings = vmSettings
        dictStore.wvDict = addWKWebView(webViewHolder: wvDictHolder)
        dictStore.wvDict.navigationDelegate = self

        Task {
            await vmSettings.getData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        vmSettings.$selectedLangIndex.didSet.filter { $0 != -1 }.sink { [unowned self] _ in
            btnLang.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrLanguages.map(\.LANGNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vmSettings.selectedLangIndex ? .on : .off) { _ in
                    guard index != vmSettings.selectedLangIndex else {return}
                    vmSettings.selectedLangIndex = index
                }
            })
            btnLang.showsMenuAsPrimaryAction = true
            btnLang.setTitle(vmSettings.selectedLang.LANGNAME, for: .normal)
        } ~ subscriptions

        vmSettings.$selectedDictReferenceIndex.didSet.filter { $0 != -1 }.sink { [unowned self] _ in
            btnDict.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrDictsReference.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vmSettings.selectedDictReferenceIndex ? .on : .off) { _ in
                    guard index != vmSettings.selectedDictReferenceIndex else {return}
                    vmSettings.selectedDictReferenceIndex = index
                }
            })
            btnDict.showsMenuAsPrimaryAction = true
            btnDict.setTitle(vmSettings.selectedDictReference.DICTNAME, for: .normal)
            dictStore.dict = vmSettings.selectedDictReference
            dictStore.searchDict()
        } ~ subscriptions

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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dictStore.onNavigationFinished()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
