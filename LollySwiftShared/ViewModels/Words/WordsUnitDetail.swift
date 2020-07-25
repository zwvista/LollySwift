//
//  WordsUnitDetail.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsUnitDetailViewModel: NSObject {
    var vm: WordsUnitViewModel!
    var item: MUnitWord!
    var complete: (() -> Void)?
    var vmSingle: SingleWordViewModel!
    var disposeBag: DisposeBag!
    var isAdd: Bool!

    init(vm: WordsUnitViewModel, item: MUnitWord, okComplete: (() -> Void)?, initComplete: @escaping () -> ()) {
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
            vm.create(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        } else {
            vm.update(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        }
    }
}
