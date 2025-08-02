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
import Then

class PatternsWebPageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvWebPageHolder: UIView!
    @IBOutlet weak var btnPattern: UIButton!
    weak var wvWebPage: WKWebView!

    var vm: PatternsWebPageViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        wvWebPage = addWKWebView(webViewHolder: wvWebPageHolder).then {
            $0.navigationDelegate = self
            $0.addGestureRecognizer(UISwipeGestureRecognizer().then {
                $0.direction = .left
                $0.delegate = self
                $0.rx.event.subscribe { [unowned self]  _ in
                    vm.next(-1)
                } ~ rx.disposeBag
            })
            $0.addGestureRecognizer(UISwipeGestureRecognizer().then {
                $0.direction = .right
                $0.delegate = self
                $0.rx.event.subscribe { [unowned self]  _ in
                    vm.next(1)
                } ~ rx.disposeBag
            })
        }
        vm.selectedPatternIndex_.subscribe { [unowned self] _ in
            btnPattern.menu = UIMenu(title: "", options: .displayInline, children: vm.arrPatterns.enumerated().map { index, item in
                UIAction(title: item.PATTERN, state: index == vm.selectedPatternIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedPatternIndex = index
                }
            })
            btnPattern.showsMenuAsPrimaryAction = true
            AppDelegate.speak(string: vm.selectedPattern.PATTERN)
            btnPattern.setTitle(vm.selectedPattern.PATTERN, for: .normal)
            wvWebPage.load(URLRequest(url: URL(string: vm.selectedPattern.URL)!))
        } ~ rx.disposeBag
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
