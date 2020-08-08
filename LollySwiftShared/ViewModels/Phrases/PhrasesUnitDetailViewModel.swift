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
    var vmSingle: SinglePhraseViewModel!
    var isAdd: Bool!

    init(vm: PhrasesUnitViewModel, item: MUnitPhrase, complete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        isAdd = item.ID == 0
        guard !isAdd else {return}
        vmSingle = SinglePhraseViewModel(phrase: item.PHRASE, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() -> Observable<()> {
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        if isAdd {
            vm.arrPhrases.append(item)
            return vm.create(item: item)
        } else {
            return vm.update(item: item)
        }
    }
}
