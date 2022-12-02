//
//  PhrasesUnitBatchEditViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation

class PhrasesUnitBatchEditViewModel: NSObject, ObservableObject {
    var vm: PhrasesUnitViewModel!
    @Published var isOKEnabled = false

    @Published var indexUNIT = 0
    var UNIT: Int { vm.vmSettings.arrUnits[indexUNIT].value }
    @Published var indexPART = 0
    var PART: Int { vm.vmSettings.arrParts[indexPART].value }
    @Published var SEQNUM = ""
    @Published var unitChecked = false
    @Published var partChecked = false
    @Published var seqnumChecked = false

    init(vm: PhrasesUnitViewModel, unit: Int, part: Int) {
        self.vm = vm
        indexUNIT.accept(vm.vmSettings.arrUnits.firstIndex { $0.value == unit }!)
        indexPART.accept(vm.vmSettings.arrParts.firstIndex { $0.value == part }!)
    }
    
    func onOK(rows: [Bool]) -> Single<()> {
        var o = Single.just(())
        for (i, isChecked) in rows.enumerated() {
            guard isChecked else {continue}
            let item = vm.arrPhrases[i]
            if unitChecked.value || partChecked.value || seqnumChecked.value {
                if unitChecked.value { item.UNIT = UNIT }
                if partChecked.value { item.PART = PART }
                if seqnumChecked.value { item.SEQNUM += Int(SEQNUM.value)! }
                o = o.flatMap { self.vm.update(item: item) }
            }
        }
        return o
    }
}
