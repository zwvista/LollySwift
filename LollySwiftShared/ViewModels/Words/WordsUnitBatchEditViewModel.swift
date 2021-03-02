//
//  WordsUnitBatchEditViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class WordsUnitBatchEditViewModel: NSObject {
    var vm: WordsUnitViewModel!
    var item: MUnitWord!
    var itemEdit: MUnitWordEdit!
    let isOKEnabled = BehaviorRelay(value: false)

    let indexUNIT = BehaviorRelay(value: 0)
    let indexPART = BehaviorRelay(value: 0)
    let SEQNUM = BehaviorRelay(value: "")
    let unitIsChecked = BehaviorRelay(value: false)
    let partIsChecked = BehaviorRelay(value: false)
    let seqnumIsChecked = BehaviorRelay(value: false)

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
            let item2 = MUnitWord()
            copyProperties(from: item, to: item2)
            item2.WORD = vm.vmSettings.autoCorrectInput(text: s)
            o = o.flatMap { [unowned self] _ in self.vm.create(item: item2) }
            item.SEQNUM += 1
        }
        return o
    }
}
