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
    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] {
        return vm.arrWordsFiltered ?? vm.arrWords
    }
    let disposeBag = DisposeBag()

    func settingsChanged() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel, inTextbook: true, disposeBag: disposeBag) {}
    }
    
    @IBAction func newTest(_ sender: Any) {
    }
}
