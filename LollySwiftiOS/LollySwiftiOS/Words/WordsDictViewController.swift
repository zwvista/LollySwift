//
//  WordsDictViewController.swift
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

class WordsDictViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var wvDictHolder: UIView!
    @IBOutlet weak var btnWord: UIButton!
    @IBOutlet weak var btnDict: UIButton!
    var dictStore: DictStore!

    let vm = WordsDictViewModel(settings: vmSettings, needCopy: false) {}
    let ddWord = DropDown(), ddDictReference = DropDown()
    
    var dictStatus = DictWebViewStatus.ready

    override func viewDidLoad() {
        super.viewDidLoad()
        dictStore = DictStore(settings: vmSettings, wvDict: addWKWebView(webViewHolder: wvDictHolder))
        dictStore.wvDict.navigationDelegate = self
        let swipeGesture1 = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeGesture1.direction = .left
        swipeGesture1.delegate = self
        dictStore.wvDict.addGestureRecognizer(swipeGesture1)
        let swipeGesture2 = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeGesture2.direction = .right
        swipeGesture2.delegate = self
        dictStore.wvDict.addGestureRecognizer(swipeGesture2)

        ddWord.anchorView = btnWord
        ddWord.dataSource = vm.arrWords
        ddWord.selectRow(vm.currentWordIndex)
        ddWord.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.currentWordIndex = index
            self.currentWordChanged()
        }
        
        ddDictReference.anchorView = btnDict
        ddDictReference.dataSource = vmSettings.arrDictsReference.map(\.DICTNAME)
        ddDictReference.selectRow(vmSettings.selectedDictReferenceIndex)
        ddDictReference.selectionAction = { [unowned self] (index: Int, item: String) in
            vmSettings.selectedDictReferenceIndex = index
            vmSettings.updateDictReference().subscribe(onSuccess: {
                self.selectDictChanged()
            }) ~ self.rx.disposeBag
        }
        
        currentWordChanged()
    }
    
    private func currentWordChanged() {
        AppDelegate.speak(string: vm.currentWord)
        btnWord.setTitle(vm.currentWord, for: .normal)
        dictStore.word = vm.currentWord
        selectDictChanged()
    }
    
    private func selectDictChanged() {
        btnDict.setTitle(vmSettings.selectedDictReference.DICTNAME, for: .normal)
        dictStore.dict = vmSettings.selectedDictReference
        dictStore.searchDict()
    }
    
    @IBAction func showWordDropDown(_ sender: AnyObject) {
        ddWord.show()
    }
    
    @IBAction func showDictDropDown(_ sender: AnyObject) {
        ddDictReference.show()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    private func swipe(_ delta: Int) {
        vm.next(delta)
        ddWord.selectionAction!(vm.currentWordIndex, vm.currentWord)
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer){
        swipe(-1)
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer){
        swipe(1)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dictStore.onNavigationFinished()
    }

}
