//
//  WordsUnitBatchAddViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class WordsUnitBatchAddViewModel: NSObject {
    var vm: WordsUnitViewModel!
    var item: MUnitWord!
    var itemEdit: MUnitWordEdit!
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: WordsUnitViewModel) {
        self.vm = vm
        item = vm.newUnitWord()
        itemEdit = MUnitWordEdit(x: item)
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        var o = Observable.just(())
        let words = itemEdit.WORDS.value.split("\n")
        for s in words {
            item.WORD = vm.vmSettings.autoCorrectInput(text: s)
            o = o.concat(vm.create(item: item))
            item.SEQNUM += 1
        }
        return o
    }
}
