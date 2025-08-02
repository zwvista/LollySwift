//
//  UnitBlogPostsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import Combine
import Then

class UnitBlogPostsViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvBlogPostHolder: UIView!
    @IBOutlet weak var btnUnit: UIButton!
    weak var wvBlogPost: WKWebView!

    var vm = UnitBlogPostsViewModel()
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wvBlogPost = addWKWebView(webViewHolder: wvBlogPostHolder).then {
            $0.navigationDelegate = self
            $0.addGestureRecognizer(UISwipeGestureRecognizer().then {
                $0.direction = .left
                $0.delegate = self
                $0.swipePublisher.sink { [unowned self]  _ in
                    vm.next(-1)
                } ~ subscriptions
            })
            $0.addGestureRecognizer(UISwipeGestureRecognizer().then {
                $0.direction = .right
                $0.delegate = self
                $0.swipePublisher.sink { [unowned self]  _ in
                    vm.next(-1)
                } ~ subscriptions
            })
        }
        vm.$selectedUnitIndex.didSet.sink { [unowned self] _ in
            btnUnit.menu = UIMenu(title: "", options: .displayInline, children: vm.arrUnits.enumerated().map { index, item in
                UIAction(title: item.label, state: index == vm.selectedUnitIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedUnitIndex = index
                }
            })
            btnUnit.showsMenuAsPrimaryAction = true
            Task {
                btnUnit.setTitle(String(vm.selectedUnit), for: .normal)
                let content = await vmSettings.getBlogContent(unit: vm.selectedUnit)
                let str = BlogPostEditViewModel.markedToHtml(text: content)
                wvBlogPost.loadHTMLStringWithMagic(content: str, baseURL: nil)
            }
        } ~ subscriptions
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
