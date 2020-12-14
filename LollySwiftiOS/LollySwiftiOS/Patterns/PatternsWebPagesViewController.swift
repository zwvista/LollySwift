//
//  PatternsWebPagesViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import DropDown
import RxSwift
import NSObject_Rx

class PatternsWebPagesViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvWebPageHolder: UIView!
    @IBOutlet weak var btnWebPage: UIButton!
    weak var wvWebPage: WKWebView!
    
    var vm: PatternsViewModel!
    let ddWebPage = DropDown()

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

        ddWebPage.anchorView = btnWebPage
        ddWebPage.dataSource = vm.arrWebPages.map { $0.TITLE }
        ddWebPage.selectRow(vm.currentWebPageIndex)
        ddWebPage.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.currentWebPageIndex = index
            self.currentWebPageChanged()
        }
        
        currentWebPageChanged()
    }
    
    private func currentWebPageChanged() {
        AppDelegate.speak(string: vm.currentWebPageTitle)
        btnWebPage.setTitle(vm.currentWebPageTitle, for: .normal)
        navigationItem.title = vm.currentWebPageTitle
    }
    
    @IBAction func showWebPageDropDown(_ sender: AnyObject) {
        ddWebPage.show()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    private func swipe(_ delta: Int) {
        vm.next(delta)
        ddWebPage.selectionAction!(vm.currentWebPageIndex, vm.currentWebPageTitle)
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer){
        swipe(-1)
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer){
        swipe(1)
    }

}
