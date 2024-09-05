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

        vm.currentPatternIndex_.subscribe { [unowned self] _ in
            btnPattern.menu = UIMenu(title: "", options: .displayInline, children: vm.arrPatterns.enumerated().map { index, item in
                UIAction(title: item.PATTERN, state: index == vm.currentPatternIndex ? .on : .off) { [unowned self] _ in
                    vm.currentPatternIndex = index
                }
            })
            btnPattern.showsMenuAsPrimaryAction = true
            currentPatternChanged()
        } ~ rx.disposeBag
    }

    private func currentPatternChanged() {
        AppDelegate.speak(string: vm.currentPattern.PATTERN)
        btnPattern.setTitle(vm.currentPattern.PATTERN, for: .normal)
        wvWebPage.load(URLRequest(url: URL(string: vm.currentPattern.URL)!))
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        currentPatternChanged()
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
