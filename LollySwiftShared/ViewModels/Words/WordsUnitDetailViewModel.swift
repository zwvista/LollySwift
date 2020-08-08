//
//  WordsUnitDetailViewModel.swift
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
    var vmSingle: SingleWordViewModel!
    var isAdd: Bool!

    init(vm: WordsUnitViewModel, item: MUnitWord, complete: @escaping () -> ()) {
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
            return vm.create(item: item)
        } else {
            return vm.update(item: item)
        }
    }
}
