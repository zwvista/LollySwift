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

    var vmGroup: LangBlogGroupsViewModel!
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

        vm.$currentLangBlogPostIndex.didSet.sink { [unowned self] _ in
            btnLangBlogPost.menu = UIMenu(title: "", options: .displayInline, children: vm.arrLangBlogPosts.enumerated().map { index, item in
                UIAction(title: item.TITLE, state: index == vm.currentLangBlogPostIndex ? .on : .off) { [unowned self] _ in
                    vm.currentLangBlogPostIndex = index
                }
            })
            btnLangBlogPost.showsMenuAsPrimaryAction = true
            Task {
                await currentLangBlogPostIndexChanged()
            }
        } ~ subscriptions
    }

    private func currentLangBlogPostIndexChanged() async {
        btnLangBlogPost.setTitle(String(vm.currentLangBlogPost.TITLE), for: .normal)
        vmGroup.selectPost(vm.currentLangBlogPost) { [unowned self] in
            wvBlogPost.loadHTMLString(BlogPostEditViewModel.markedToHtml(text: vmGroup.postContent), baseURL: nil)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        Task {
            await currentLangBlogPostIndexChanged()
        }
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
