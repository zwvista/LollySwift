//
//  WordsLangDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class WordsLangDetailViewModel: NSObject {
    var vm: WordsLangViewModel
    var item: MLangWord
    var itemEdit: MLangWordEdit
    var vmSingle: SingleWordViewModel
    var isAdd: Bool
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: WordsLangViewModel, item: MLangWord) {
        self.vm = vm
        self.item = item
        itemEdit = MLangWordEdit(x: item)
        isAdd = item.ID == 0
        vmSingle = SingleWordViewModel(word: isAdd ? "" : item.WORD, settings: vm.vmSettings)
        super.init()
        _ = itemEdit.WORD.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        return isAdd ? WordsLangViewModel.create(item: item) : WordsLangViewModel.update(item: item)
    }
}
