//
//  PhrasesUnitDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesUnitDetailViewModel: NSObject {
    var vm: PhrasesUnitViewModel!
    var item: MUnitPhrase!
    var complete: (() -> Void)?
    var vmSingle: SinglePhraseViewModel!
    var isAdd: Bool!

    init(vm: PhrasesUnitViewModel, item: MUnitPhrase, okComplete: (() -> Void)?, initComplete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        self.complete = okComplete
        isAdd = item.ID == 0
        guard !isAdd else {return}
        vmSingle = SinglePhraseViewModel(phrase: item.PHRASE, settings: vm.vmSettings, complete: initComplete)
    }
    
    func onOK() {
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        if isAdd {
            vm.arrPhrases.append(item)
            vm.create(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        } else {
            vm.update(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        }
    }
}
