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

    init(vm: WordsUnitViewModel, item: MUnitWord, disposeBag: DisposeBag, okComplete: (() -> Void)?, initComplete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        self.disposeBag = disposeBag
        self.complete = okComplete
        isAdd = item.ID == 0
        guard !isAdd else {return}
        vmSingle = SingleWordViewModel(word: item.WORD, settings: vm.vmSettings, disposeBag: disposeBag, complete: initComplete)
    }
    
    func onOK() {
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        if isAdd {
            vm.arrWords.append(item)
            WordsUnitViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            WordsUnitViewModel.update(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
    }
}
