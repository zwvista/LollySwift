//
//  PatternsWebPageViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import NSObject_Rx
import RxBinding

class PatternsWebPageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvWebPageHolder: UIView!
    @IBOutlet weak var btnPattern: UIButton!
    weak var wvWebPage: WKWebView!

    var vm: PatternsWebPageViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        wvWebPage = addWKWebView(webViewHolder: wvWebPageHolder)
        wvWebPage.navigationDelegate = self

        let swipeGesture1 = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeGesture1.direction = .left
        swipeGesture1.delegate = self
        wvWebPage.addGestureRecognizer(swipeGesture1)
        let swipeGesture2 = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeGesture2.direction = .right
        swipeGesture2.delegate = self
        wvWebPage.addGestureRecognizer(swipeGesture2)

        vm.selectedPatternIndex_.subscribe { [unowned self] _ in
            btnPattern.menu = UIMenu(title: "", options: .displayInline, children: vm.arrPatterns.enumerated().map { index, item in
                UIAction(title: item.PATTERN, state: index == vm.selectedPatternIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedPatternIndex = index
                }
            })
            btnPattern.showsMenuAsPrimaryAction = true
            selectedPatternChanged()
        } ~ rx.disposeBag
    }

    private func selectedPatternChanged() {
        AppDelegate.speak(string: vm.selectedPattern.PATTERN)
        btnPattern.setTitle(vm.selectedPattern.PATTERN, for: .normal)
        wvWebPage.load(URLRequest(url: URL(string: vm.selectedPattern.URL)!))
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        selectedPatternChanged()
    }

    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer){
        swipe(-1)
    }

    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer){
        swipe(1)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
