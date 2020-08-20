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
    var index = -1
    var isAdd: Bool!
    var isOKEnabled = BehaviorRelay(value: false)

    init(vm: PhrasesUnitViewModel, index: Int, complete: @escaping () -> ()) {
        self.vm = vm
        self.index = index
        item = index == -1 ? vm.newUnitPhrase() : vm.arrPhrases[index]
        itemEdit = MUnitPhraseEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.PHRASE.map { !$0.isEmpty } ~> isOKEnabled
        guard !isAdd else {return}
        vmSingle = SinglePhraseViewModel(phrase: item.PHRASE, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        return isAdd ? vm.create(item: item).map {
            self.vm.arrPhrases.append($0!)
        } : vm.update(item: item).map {
            self.vm.arrPhrases[self.index] = $0!
        }
    }
}
