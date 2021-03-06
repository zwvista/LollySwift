//
//  PhrasesLangDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class PhrasesLangDetailViewModel: NSObject {
    var vm: PhrasesLangViewModel!
    var item: MLangPhrase!
    var itemEdit: MLangPhraseEdit!
    var vmSingle: SinglePhraseViewModel!
    var isAdd: Bool!
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: PhrasesLangViewModel, item: MLangPhrase, complete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        itemEdit = MLangPhraseEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.PHRASE.map { !$0.isEmpty } ~> isOKEnabled
        guard !isAdd else {return}
        vmSingle = SinglePhraseViewModel(phrase: item.PHRASE, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        if isAdd {
            vm.arrPhrases.append(item)
            return PhrasesLangViewModel.create(item: item)
        } else {
            return PhrasesLangViewModel.update(item: item)
        }
    }
}
