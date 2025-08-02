//
//  OnlineTextbooksWebPageViewController.swift
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

class OnlineTextbooksWebPageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvWebPageHolder: UIView!
    @IBOutlet weak var btnOnlineTextbook: UIButton!
    weak var wvWebPage: WKWebView!

    var vm: OnlineTextbooksWebPageViewModel!
    
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
        vm.selectedOnlineTextbookIndex_.subscribe { [unowned self] _ in
            btnOnlineTextbook.menu = UIMenu(title: "", options: .displayInline, children: vm.arrOnlineTextbooks.enumerated().map { index, item in
                UIAction(title: item.TITLE, state: index == vm.selectedOnlineTextbookIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedOnlineTextbookIndex = index
                }
            })
            btnOnlineTextbook.showsMenuAsPrimaryAction = true
            AppDelegate.speak(string: vm.selectedOnlineTextbook.TITLE)
            btnOnlineTextbook.setTitle(vm.selectedOnlineTextbook.TITLE, for: .normal)
            wvWebPage.load(URLRequest(url: URL(string: vm.selectedOnlineTextbook.URL)!))
        } ~ rx.disposeBag
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
