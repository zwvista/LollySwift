//
//  WordsDictViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import Combine
import Then

class WordsDictViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvDictHolder: UIView!
    @IBOutlet weak var btnWord: UIButton!
    @IBOutlet weak var btnDict: UIButton!

    let dictStore = DictStore()
    var vm: WordsDictViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        dictStore.wvDict = addWKWebView(webViewHolder: wvDictHolder).then {
            $0.navigationDelegate = self
            $0.addGestureRecognizer(UISwipeGestureRecognizer().then {
                $0.direction = .left
                $0.delegate = self
                $0.swipePublisher.sink { [unowned self]  _ in
                    vm.next(-1)
                } ~ subscriptions
            })
            $0.addGestureRecognizer(UISwipeGestureRecognizer().then {
                $0.direction = .right
                $0.delegate = self
                $0.swipePublisher.sink { [unowned self] _ in
                    vm.next(1)
                } ~ subscriptions
            })
        }
        vm.$selectedWordIndex.didSet.sink { [unowned self] _ in
            btnWord.menu = UIMenu(title: "", options: .displayInline, children: vm.arrWords.enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedWordIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedWordIndex = index
                }
            })
            btnWord.showsMenuAsPrimaryAction = true
            AppDelegate.speak(string: vm.selectedWord)
            btnWord.setTitle(vm.selectedWord, for: .normal)
            dictStore.word = vm.selectedWord
            selectDictChanged()
        } ~ subscriptions
        vmSettings.$selectedDictReferenceIndex.didSet.sink { [unowned self] _ in
            btnDict.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrDictsReference.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vmSettings.selectedDictReferenceIndex ? .on : .off) { _ in
                    vmSettings.selectedDictReferenceIndex = index
                }
            })
            btnDict.showsMenuAsPrimaryAction = true
            selectDictChanged()
        } ~ subscriptions
    }

    private func selectDictChanged() {
        btnDict.setTitle(vmSettings.selectedDictReference.DICTNAME, for: .normal)
        dictStore.dict = vmSettings.selectedDictReference
        dictStore.searchDict()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dictStore.onNavigationFinished()
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
