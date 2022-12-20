//
//  PatternsWebPagesBrowseViewController.swift
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
import RxBinding

class PatternsWebPagesBrowseViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvWebPageHolder: UIView!
    @IBOutlet weak var btnWebPage: UIButton!
    weak var wvWebPage: WKWebView!

    var vm: PatternsWebPagesViewModel!
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

        vm.getWebPages().subscribe { _ in
            self.ddWebPage.anchorView = self.btnWebPage
            self.ddWebPage.dataSource = self.vm.arrWebPages.map(\.TITLE)
            self.ddWebPage.selectRow(self.vm.currentWebPageIndex)
            self.ddWebPage.selectionAction = { [unowned self] (index: Int, item: String) in
                self.vm.currentWebPageIndex = index
                self.currentWebPageChanged()
            }
            self.currentWebPageChanged()
        } ~ rx.disposeBag
    }

    private func currentWebPageChanged() {
        AppDelegate.speak(string: vm.currentWebPage.TITLE)
        btnWebPage.setTitle(vm.currentWebPage.TITLE, for: .normal)
        wvWebPage.load(URLRequest(url: URL(string: vm.currentWebPage.URL)!))
    }

    @IBAction func showWebPageDropDown(_ sender: AnyObject) {
        ddWebPage.show()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        ddWebPage.selectionAction!(vm.currentWebPageIndex, vm.currentWebPage.TITLE)
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
            controller.vmEdit.onOK().subscribe() ~ rx.disposeBag
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
