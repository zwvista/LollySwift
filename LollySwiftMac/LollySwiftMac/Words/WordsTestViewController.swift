//
//  WordsTestViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class WordsTestViewController: NSViewController, LollyProtocol {
    var vm: WordsTestViewModel!
    let disposeBag = DisposeBag()

    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfWordTarget: NSTextField!
    
    func settingsChanged() {
        vm = WordsTestViewModel(settings: AppDelegate.theSettingsViewModel)
        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }
    
    @IBAction func newTest(_ sender: Any) {
        vm.newTest().subscribe {
            self.next(self)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func next(_ sender: Any) {
        tfWordTarget.stringValue = vm.currentWord
        vm.getTranslation().subscribe(onNext: {
            self.tfTranslation.stringValue = $0
            self.vm.next()
        }).disposed(by: disposeBag)
    }
}
