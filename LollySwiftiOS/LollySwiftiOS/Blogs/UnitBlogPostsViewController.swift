//
//  UnitBlogPostsViewController.swift
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

class UnitBlogPostsViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvBlogPostHolder: UIView!
    @IBOutlet weak var btnUnit: UIButton!
    weak var wvBlogPost: WKWebView!

    var vm = UnitBlogPostsViewModel(settings: vmSettings) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wvBlogPost = addWKWebView(webViewHolder: wvBlogPostHolder)
        wvBlogPost.navigationDelegate = self

        let swipeGesture1 = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeGesture1.direction = .left
        swipeGesture1.delegate = self
        wvBlogPost.addGestureRecognizer(swipeGesture1)
        let swipeGesture2 = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeGesture2.direction = .right
        swipeGesture2.delegate = self
        wvBlogPost.addGestureRecognizer(swipeGesture2)

        vm.selectedUnitIndex_.subscribe { [unowned self] _ in
            btnUnit.menu = UIMenu(title: "", options: .displayInline, children: vm.arrUnits.enumerated().map { index, item in
                UIAction(title: item.label, state: index == vm.selectedUnitIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedUnitIndex = index
                }
            })
            btnUnit.showsMenuAsPrimaryAction = true
            selectedUnitIndexChanged()
        } ~ rx.disposeBag
    }

    private func selectedUnitIndexChanged() {
        btnUnit.setTitle(String(vm.selectedUnit), for: .normal)
        vmSettings.getBlogContent(unit: vm.selectedUnit).subscribe { [unowned self] content in
            let str = BlogPostEditViewModel.markedToHtml(text: content)
            self.wvBlogPost.loadHTMLString(str, baseURL: nil)
        } ~ rx.disposeBag
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        selectedUnitIndexChanged()
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
