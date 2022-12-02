//
//  PhrasesUnitDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class PhrasesUnitDetailViewModel: NSObject {
    var vm: PhrasesUnitViewModel!
    var item: MUnitPhrase!
    var wordid: Int
    var itemEdit: MUnitPhraseEdit!
    var vmSingle: SinglePhraseViewModel!
    var isAdd: Bool!
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: PhrasesUnitViewModel, item: MUnitPhrase, wordid: Int, complete: @escaping () -> Void) {
        self.vm = vm
        self.item = item
        self.wordid = wordid
        itemEdit = MUnitPhraseEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.PHRASE.map { !$0.isEmpty } ~> isOKEnabled
        guard !isAdd else {return}
        vmSingle = SinglePhraseViewModel(phrase: item.PHRASE, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        return !isAdd ? vm.update(item: item) : vm.create(item: item).flatMap {
            self.wordid == 0 ? Single.just(()) : MWordPhrase.associate(wordid: self.wordid, phraseid: self.item.PHRASEID)
        }
    }
}
