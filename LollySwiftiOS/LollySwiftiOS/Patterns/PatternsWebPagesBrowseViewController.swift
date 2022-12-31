//
//  PatternsWebPagesBrowseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import Combine

class PatternsWebPagesBrowseViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvWebPageHolder: UIView!
    @IBOutlet weak var btnWebPage: UIButton!
    weak var wvWebPage: WKWebView!

    var vm: PatternsWebPagesViewModel!
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

        Task {
            await vm.getWebPages()

            @MainActor
            func configMenu() {
                let arr = vm.arrWebPages.map(\.TITLE)
                btnWebPage.menu = UIMenu(title: "", options: .displayInline, children: arr.enumerated().map { index, item in
                    UIAction(title: "\(index + 1)/\(arr.count) \(item)", state: index == vm.currentWebPageIndex ? .on : .off) { [unowned self] _ in
                        vm.currentWebPageIndex = index
                        currentWebPageChanged()
                        configMenu()
                    }
                })
                btnWebPage.showsMenuAsPrimaryAction = true
            }
            configMenu()
            currentWebPageChanged()
        }
    }

    private func currentWebPageChanged() {
        AppDelegate.speak(string: vm.currentWebPage.TITLE)
        btnWebPage.setTitle(vm.currentWebPageText, for: .normal)
        wvWebPage.load(URLRequest(url: URL(string: vm.currentWebPage.URL)!))
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        currentWebPageChanged()
    }

    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer){
        swipe(-1)
    }

    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer){
        swipe(1)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PatternsWebPagesDetailViewController {
            let item = segue.identifier == "add" ? vm.newPatternWebPage() : vm.currentWebPage
            controller.startEdit(item: item)
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? PatternsWebPagesDetailViewController {
            Task {
                await controller.vmEdit.onOK()
            }
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
