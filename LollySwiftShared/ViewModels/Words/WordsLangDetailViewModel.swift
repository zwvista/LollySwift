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
    var complete: (() -> Void)?
    var vmSingle: SingleWordViewModel!
    var isAdd: Bool!

    init(vm: WordsLangViewModel, item: MLangWord, okComplete: (() -> Void)?, initComplete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        self.complete = okComplete
        isAdd = item.ID == 0
        guard !isAdd else {return}
        vmSingle = SingleWordViewModel(word: item.WORD, settings: vm.vmSettings, complete: initComplete)
    }
    
    func onOK() {
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        if isAdd {
            vm.arrWords.append(item)
            WordsLangViewModel.create(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        } else {
            WordsLangViewModel.update(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        }
    }
}
