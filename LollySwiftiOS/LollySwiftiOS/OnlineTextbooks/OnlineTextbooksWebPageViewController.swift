//
//  OnlineTextbooksWebPageViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import Combine

class OnlineTextbooksWebPageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvWebPageHolder: UIView!
    @IBOutlet weak var btnOnlineTextbook: UIButton!
    weak var wvWebPage: WKWebView!

    var vm: OnlineTextbooksWebPageViewModel!
    var subscriptions = Set<AnyCancellable>()
    
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

        vm.$currentOnlineTextbookIndex.didSet.sink { [unowned self] _ in
            btnOnlineTextbook.menu = UIMenu(title: "", options: .displayInline, children: vm.arrOnlineTextbooks.enumerated().map { index, item in
                UIAction(title: item.TITLE, state: index == vm.currentOnlineTextbookIndex ? .on : .off) { [unowned self] _ in
                    vm.currentOnlineTextbookIndex = index
                }
            })
            btnOnlineTextbook.showsMenuAsPrimaryAction = true
            currentOnlineTextbookChanged()
        } ~ subscriptions
    }

    private func currentOnlineTextbookChanged() {
        AppDelegate.speak(string: vm.currentOnlineTextbook.TITLE)
        btnOnlineTextbook.setTitle(vm.currentOnlineTextbook.TITLE, for: .normal)
        wvWebPage.load(URLRequest(url: URL(string: vm.currentOnlineTextbook.URL)!))
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        currentOnlineTextbookChanged()
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
