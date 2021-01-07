//
//  PhrasesUnitBatchAddViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class PhrasesUnitBatchAddViewModel: NSObject {
    var vm: PhrasesUnitViewModel!
    var item: MUnitPhrase!
    var itemEdit: MUnitPhraseEdit!
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: PhrasesUnitViewModel) {
        self.vm = vm
        item = vm.newUnitPhrase()
        itemEdit = MUnitPhraseEdit(x: item)
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        var o = Observable.just(())
        let phrases = itemEdit.PHRASES.value.split("\n")
        for i in stride(from: 0, to: phrases.count, by: 2) {
            item.PHRASE = vm.vmSettings.autoCorrectInput(text: phrases[i])
            item.TRANSLATION = phrases[i + 1]
            o = o.concat(vm.create(item: item))
            item.SEQNUM += 1
        }
        return o
    }
}
