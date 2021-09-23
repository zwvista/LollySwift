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
    
    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        var o = Single.just(())
        let words = itemEdit.WORDS.value.split(separator: "\n")
        for s in words {
            let item2 = MUnitWord()
            copyProperties(from: item, to: item2)
            item2.WORD = vm.vmSettings.autoCorrectInput(text: String(s))
            o = o.flatMap {
                self.vm.create(item: item2)
            }
            item.SEQNUM += 1
        }
        return o
    }
}
