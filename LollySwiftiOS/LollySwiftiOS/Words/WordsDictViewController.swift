//
//  WordsDictViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit

class WordsDictViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvDictHolder: UIView!
    @IBOutlet weak var btnWord: UIButton!
    @IBOutlet weak var btnDict: UIButton!

    let dictStore = DictStore()
    var vm: WordsDictViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        dictStore.vmSettings = vmSettings
        dictStore.wvDict = addWKWebView(webViewHolder: wvDictHolder)
        dictStore.wvDict.navigationDelegate = self
        let swipeGesture1 = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeGesture1.direction = .left
        swipeGesture1.delegate = self
        dictStore.wvDict.addGestureRecognizer(swipeGesture1)
        let swipeGesture2 = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeGesture2.direction = .right
        swipeGesture2.delegate = self
        dictStore.wvDict.addGestureRecognizer(swipeGesture2)
        currentWordChanged()
    }

    private func currentWordChanged() {
        AppDelegate.speak(string: vm.currentWord)
        btnWord.setTitle(vm.currentWord, for: .normal)
        dictStore.word = vm.currentWord
        btnWord.menu = UIMenu(title: "", options: .displayInline, children: vm.arrWords.enumerated().map { index, item in
            UIAction(title: item, state: index == vm.currentWordIndex ? .on : .off) { [unowned self] _ in
                vm.currentWordIndex = index
            }
        })
        btnWord.showsMenuAsPrimaryAction = true
        selectDictChanged()
    }

    private func selectDictChanged() {
        btnDict.setTitle(vmSettings.selectedDictReference.DICTNAME, for: .normal)
        dictStore.dict = vmSettings.selectedDictReference
        dictStore.searchDict()
        btnDict.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrDictsReference.map(\.DICTNAME).enumerated().map { index, item in
            UIAction(title: item, state: index == vm.currentWordIndex ? .on : .off) { _ in
                vmSettings.selectedDictReferenceIndex = index
            }
        })
        btnDict.showsMenuAsPrimaryAction = true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        currentWordChanged()
    }

    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer){
        swipe(-1)
    }

    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer){
        swipe(1)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dictStore.onNavigationFinished()
    }

}
