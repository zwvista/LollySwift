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
import Then

class UnitBlogPostsViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvBlogPostHolder: UIView!
    @IBOutlet weak var btnUnit: UIButton!
    weak var wvBlogPost: WKWebView!

    var vm = UnitBlogPostsViewModel()
    
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
        vm.selectedUnitIndex_.subscribe { [unowned self] _ in
            btnUnit.menu = UIMenu(title: "", options: .displayInline, children: vm.arrUnits.enumerated().map { index, item in
                UIAction(title: item.label, state: index == vm.selectedUnitIndex ? .on : .off) { [unowned self] _ in
                    vm.selectedUnitIndex = index
                }
            })
            btnUnit.showsMenuAsPrimaryAction = true
            btnUnit.setTitle(String(vm.selectedUnit), for: .normal)
            vmSettings.getBlogContent(unit: vm.selectedUnit).subscribe { [unowned self] content in
                let str = BlogPostEditViewModel.markedToHtml(text: content)
                self.wvBlogPost.loadHTMLStringWithMagic(content: str, baseURL: nil)
            } ~ rx.disposeBag
        } ~ rx.disposeBag
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
