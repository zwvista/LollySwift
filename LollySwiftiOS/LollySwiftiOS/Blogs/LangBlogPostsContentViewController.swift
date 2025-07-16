//
//  LangBlogPostsContentViewController.swift
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

class LangBlogPostsContentViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvBlogPostHolder: UIView!
    @IBOutlet weak var btnLangBlogPost: UIButton!
    weak var wvBlogPost: WKWebView!

    var vmGroups: LangBlogGroupsViewModel!
    var vm: LangBlogPostsContentViewModel!
    
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

        vm.selectedLangBlogPostIndex_.subscribe { [unowned self] _ in
            btnLangBlogPost.menu = UIMenu(title: "", options: .displayInline, children: vm.arrLangBlogPosts.enumerated().map { index, item in
                UIAction(title: item.TITLE, state: index == vm.selectedLangBlogPostIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedLangBlogPostIndex = index
                }
            })
            btnLangBlogPost.showsMenuAsPrimaryAction = true
            btnLangBlogPost.setTitle(String(vm.selectedLangBlogPost.TITLE), for: .normal)
            vmGroups.selectedPost = vm.selectedLangBlogPost
        } ~ rx.disposeBag
        vmGroups.postHtml_.subscribe { [unowned self] in
            wvBlogPost.loadHTMLString($0, baseURL: nil)
        } ~ rx.disposeBag
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer){
        vm.next(-1)
    }

    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer){
        vm.next(1)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
