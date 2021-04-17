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
    let isOKEnabled = BehaviorRelay(value: false)

    let indexUNIT = BehaviorRelay(value: 0)
    var UNIT: Int { vm.vmSettings.arrUnits[indexUNIT.value].value }
    let indexPART = BehaviorRelay(value: 0)
    var PART: Int { vm.vmSettings.arrParts[indexPART.value].value }
    let SEQNUM = BehaviorRelay(value: "")
    let unitIsChecked = BehaviorRelay(value: false)
    let partIsChecked = BehaviorRelay(value: false)
    let seqnumIsChecked = BehaviorRelay(value: false)

    init(vm: WordsUnitViewModel, unit: Int, part: Int) {
        self.vm = vm
        indexUNIT.accept(vm.vmSettings.arrUnits.firstIndex { $0.value == unit }!)
        indexPART.accept(vm.vmSettings.arrParts.firstIndex { $0.value == part }!)
    }
    
    func onOK(rows: [Bool]) -> Observable<()> {
        var o = Observable.just(())
        for (i, isChecked) in rows.enumerated() {
            guard isChecked else {continue}
            let item = vm.arrWords[i]
            if unitIsChecked.value || partIsChecked.value || seqnumIsChecked.value {
                if unitIsChecked.value { item.UNIT = UNIT }
                if partIsChecked.value { item.PART = PART }
                if seqnumIsChecked.value { item.SEQNUM += Int(SEQNUM.value)! }
                o = o.flatMap { [unowned self] _ in self.vm.update(item: item) }
            }
        }
        return o
    }
}
