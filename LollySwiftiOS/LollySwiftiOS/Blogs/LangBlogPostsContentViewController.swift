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
import Then

class LangBlogPostsContentViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvBlogPostHolder: UIView!
    @IBOutlet weak var btnLangBlogPost: UIButton!
    weak var wvBlogPost: WKWebView!

    var vm: LangBlogPostsContentViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wvBlogPost = addWKWebView(webViewHolder: wvBlogPostHolder).then {
            $0.navigationDelegate = self
            $0.addGestureRecognizer(UISwipeGestureRecognizer().then {
                $0.direction = .left
                $0.delegate = self
                $0.rx.event.subscribe { [unowned self] _ in
                    vm.next(-1)
                } ~ rx.disposeBag
            })
            $0.addGestureRecognizer(UISwipeGestureRecognizer().then {
                $0.direction = .right
                $0.delegate = self
                $0.rx.event.subscribe { [unowned self] _ in
                    vm.next(1)
                } ~ rx.disposeBag
            })
        }
        vm.selectedPostIndex_.subscribe { [unowned self] _ in
            btnLangBlogPost.menu = UIMenu(title: "", options: .displayInline, children: vm.arrPosts.enumerated().map { index, item in
                UIAction(title: item.TITLE, state: index == vm.selectedPostIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedPostIndex = index
                }
            })
            btnLangBlogPost.showsMenuAsPrimaryAction = true
            btnLangBlogPost.setTitle(String(vm.selectedPost.TITLE), for: .normal)
        } ~ rx.disposeBag
        vm.vmGroups.postHtml_.subscribe { [unowned self] in
            wvBlogPost.loadHTMLStringWithMagic(content: $0, baseURL: nil)
        } ~ rx.disposeBag
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
