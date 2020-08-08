//
//  PhrasesUnitEditViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class PhrasesUnitEditViewModel: NSObject {
    var vm: PhrasesUnitViewModel!
    var item: MUnitPhrase!
    var itemEdit: MUnitPhraseEdit!
    var vmSingle: SinglePhraseViewModel!
    var isAdd: Bool!
    var isOKEnabled = BehaviorRelay(value: false)

    init(vm: PhrasesUnitViewModel, item: MUnitPhrase, complete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        itemEdit = MUnitPhraseEdit(x: item)
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
            return vm.create(item: item)
        } else {
            return vm.update(item: item)
        }
    }
}
