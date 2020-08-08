//
//  PhrasesLangDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesLangDetailViewModel: NSObject {
    var vm: PhrasesLangViewModel!
    var item: MLangPhrase!
    var vmSingle: SinglePhraseViewModel!
    var isAdd: Bool!

    init(vm: PhrasesLangViewModel, item: MLangPhrase, complete: @escaping () -> ()) {
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
            return PhrasesLangViewModel.create(item: item)
        } else {
            return PhrasesLangViewModel.update(item: item)
        }
    }
}
