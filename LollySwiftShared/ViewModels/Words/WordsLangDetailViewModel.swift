//
//  WordsLangDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsLangDetailViewModel: NSObject {
    var vm: WordsLangViewModel!
    var item: MLangWord!
    var vmSingle: SingleWordViewModel!
    var isAdd: Bool!

    init(vm: WordsLangViewModel, item: MLangWord, complete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        isAdd = item.ID == 0
        guard !isAdd else {return}
        vmSingle = SingleWordViewModel(word: item.WORD, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() -> Observable<()> {
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        if isAdd {
            vm.arrWords.append(item)
            return WordsLangViewModel.create(item: item)
        } else {
            return WordsLangViewModel.update(item: item)
        }
    }
}
