//
//  WordsUnitDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class WordsUnitDetailViewModel: NSObject {
    var vm: WordsUnitViewModel
    var item: MUnitWord
    var phraseid: Int
    var itemEdit: MUnitWordEdit
    var vmSingle: SingleWordViewModel
    var isAdd: Bool
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: WordsUnitViewModel, item: MUnitWord, phraseid: Int) {
        self.vm = vm
        self.item = item
        self.phraseid = phraseid
        itemEdit = MUnitWordEdit(x: item)
        isAdd = item.ID == 0
        vmSingle = SingleWordViewModel(word: isAdd ? "" : item.WORD)
        super.init()
        _ = itemEdit.WORD.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        item.WORD = vmSettings.autoCorrectInput(text: item.WORD)
        return !isAdd ? vm.update(item: item) : vm.create(item: item).flatMap { [unowned self] in
            phraseid == 0 ? Single.just(()) : MWordPhrase.associate(wordid: item.WORDID, phraseid: phraseid)
        }
    }
}
