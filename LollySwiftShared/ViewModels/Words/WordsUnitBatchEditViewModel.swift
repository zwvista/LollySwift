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
    var vm: WordsUnitViewModel
    let isOKEnabled = BehaviorRelay(value: false)

    let indexUNIT = BehaviorRelay(value: 0)
    var UNIT: Int { vmSettings.arrUnits[indexUNIT.value].value }
    let indexPART = BehaviorRelay(value: 0)
    var PART: Int { vmSettings.arrParts[indexPART.value].value }
    let SEQNUM = BehaviorRelay(value: "")
    let unitChecked = BehaviorRelay(value: false)
    let partChecked = BehaviorRelay(value: false)
    let seqnumChecked = BehaviorRelay(value: false)

    init(vm: WordsUnitViewModel, unit: Int, part: Int) {
        self.vm = vm
        indexUNIT.accept(vmSettings.arrUnits.firstIndex { $0.value == unit }!)
        indexPART.accept(vmSettings.arrParts.firstIndex { $0.value == part }!)
    }

    func onOK(rows: [Bool]) -> Single<()> {
        var o = Single.just(())
        for (i, isChecked) in rows.enumerated() {
            guard isChecked else {continue}
            let item = vm.arrWordsAll[i]
            if unitChecked.value || partChecked.value || seqnumChecked.value {
                if unitChecked.value { item.UNIT = UNIT }
                if partChecked.value { item.PART = PART }
                if seqnumChecked.value { item.SEQNUM += Int(SEQNUM.value)! }
                o = o.flatMap { [unowned self] in vm.update(item: item) }
            }
        }
        return o
    }
}
