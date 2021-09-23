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

class WordsLangDetailViewModel: NSObject {
    var vm: WordsLangViewModel!
    var item: MLangWord!
    var itemEdit: MLangWordEdit!
    var vmSingle: SingleWordViewModel!
    var isAdd: Bool!
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: WordsLangViewModel, item: MLangWord, complete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        itemEdit = MLangWordEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.WORD.map { !$0.isEmpty } ~> isOKEnabled
        guard !isAdd else {return}
        vmSingle = SingleWordViewModel(word: item.WORD, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        return isAdd ? WordsLangViewModel.create(item: item) : WordsLangViewModel.update(item: item)
    }
}
