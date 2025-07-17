//
//  LangBlogPostsContentViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import Combine

class LangBlogPostsContentViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvBlogPostHolder: UIView!
    @IBOutlet weak var btnLangBlogPost: UIButton!
    weak var wvBlogPost: WKWebView!

    var vm: LangBlogPostsContentViewModel!
    var subscriptions = Set<AnyCancellable>()
    
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

        vm.$selectedPostIndex.didSet.sink { [unowned self] _ in
            btnLangBlogPost.menu = UIMenu(title: "", options: .displayInline, children: vm.arrPosts.enumerated().map { index, item in
                UIAction(title: item.TITLE, state: index == vm.selectedPostIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedPostIndex = index
                }
            })
            btnLangBlogPost.showsMenuAsPrimaryAction = true
            btnLangBlogPost.setTitle(String(vm.selectedPost.TITLE), for: .normal)
        } ~ subscriptions
        vm.vmGroups.$postHtml.didSet.sink { [unowned self] in
            wvBlogPost.loadHTMLStringWithMagic(content: $0, baseURL: nil)
        } ~ subscriptions
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
