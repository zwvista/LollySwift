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
    var vm: PhrasesUnitViewModel
    var item: MUnitPhrase
    var itemEdit: MUnitPhraseEdit
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: PhrasesUnitViewModel) {
        self.vm = vm
        item = vm.newUnitPhrase()
        itemEdit = MUnitPhraseEdit(x: item)
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        var o = Single.just(())
        let phrases = itemEdit.PHRASES.value.split(separator: "\n").map { String($0) }
        for i in stride(from: 0, to: phrases.count, by: 2) {
            let item2 = MUnitPhrase()
            copyProperties(from: item, to: item2)
            item2.PHRASE = vm.vmSettings.autoCorrectInput(text: phrases[i])
            item2.TRANSLATION = phrases[i + 1]
            o = o.flatMap { self.vm.create(item: item2) }
            item.SEQNUM += 1
        }
        return o
    }
}
