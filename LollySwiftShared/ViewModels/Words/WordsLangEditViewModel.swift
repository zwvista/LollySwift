//
//  WordsLangEditViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class WordsLangEditViewModel: NSObject {
    var vm: WordsLangViewModel!
    var item: MLangWord!
    var itemEdit: MLangWordEdit!
    var vmSingle: SingleWordViewModel!
    var isAdd: Bool!
    var isOKEnabled = BehaviorRelay(value: false)

    init(vm: WordsLangViewModel, item: MLangWord, complete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        itemEdit = MLangWordEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.WORD.map { !$0.isEmpty } ~> isOKEnabled
        guard !isAdd else {return}
        vmSingle = SingleWordViewModel(word: item.WORD, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        if isAdd {
            vm.arrWords.append(item)
            return WordsLangViewModel.create(item: item)
        } else {
            return WordsLangViewModel.update(item: item)
        }
    }
}
