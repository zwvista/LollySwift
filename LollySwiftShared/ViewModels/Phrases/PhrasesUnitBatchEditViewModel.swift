//
//  PhrasesUnitBatchEditViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class PhrasesUnitBatchEditViewModel: NSObject {
    var vm: PhrasesUnitViewModel!
    let isOKEnabled = BehaviorRelay(value: false)

    let indexUNIT = BehaviorRelay(value: 0)
    var UNIT: Int { vm.vmSettings.arrUnits[indexUNIT.value].value }
    let indexPART = BehaviorRelay(value: 0)
    var PART: Int { vm.vmSettings.arrParts[indexPART.value].value }
    let SEQNUM = BehaviorRelay(value: "")
    let unitChecked = BehaviorRelay(value: false)
    let partChecked = BehaviorRelay(value: false)
    let seqnumChecked = BehaviorRelay(value: false)

    init(vm: PhrasesUnitViewModel, unit: Int, part: Int) {
        self.vm = vm
        indexUNIT.accept(vm.vmSettings.arrUnits.firstIndex { $0.value == unit }!)
        indexPART.accept(vm.vmSettings.arrParts.firstIndex { $0.value == part }!)
    }
    
    func onOK(rows: [Bool]) -> Completable {
        var o = Completable.empty()
        for (i, isChecked) in rows.enumerated() {
            guard isChecked else {continue}
            let item = vm.arrPhrases[i]
            if unitChecked.value || partChecked.value || seqnumChecked.value {
                if unitChecked.value { item.UNIT = UNIT }
                if partChecked.value { item.PART = PART }
                if seqnumChecked.value { item.SEQNUM += Int(SEQNUM.value)! }
                o = o.andThen(vm.update(item: item))
            }
        }
        return o
    }
}
