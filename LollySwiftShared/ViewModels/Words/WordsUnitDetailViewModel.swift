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

class WordsUnitDetailViewModel: NSObject {
    var vm: WordsUnitViewModel!
    var item: MUnitWord!
    var itemEdit: MUnitWordEdit!
    var vmSingle: SingleWordViewModel!
    var isAdd: Bool!
    var isOKEnabled = BehaviorRelay(value: false)

    init(vm: WordsUnitViewModel, item: MUnitWord, complete: @escaping () -> ()) {
        self.vm = vm
        self.item = item
        itemEdit = MUnitWordEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.WORD.map { !$0.isEmpty } ~> isOKEnabled
        guard !isAdd else {return}
        vmSingle = SingleWordViewModel(word: item.WORD, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        return isAdd ? vm.create(item: item) : vm.update(item: item)
    }
}
