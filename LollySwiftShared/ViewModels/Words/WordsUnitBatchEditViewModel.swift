//
//  WordsUnitBatchEditViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation

class WordsUnitBatchEditViewModel: NSObject, ObservableObject {
    var vm: WordsUnitViewModel!
    @Published var isOKEnabled = false

    @Published var indexUNIT = 0
    var UNIT: Int { vm.vmSettings.arrUnits[indexUNIT].value }
    @Published var indexPART = 0
    var PART: Int { vm.vmSettings.arrParts[indexPART].value }
    @Published var seqnumChecked = false

    init(vm: WordsUnitViewModel, unit: Int, part: Int) {
        self.vm = vm
        indexUNIT.accept(vm.vmSettings.arrUnits.firstIndex { $0.value == unit }!)
        indexPART.accept(vm.vmSettings.arrParts.firstIndex { $0.value == part }!)
    }
    
    func onOK(rows: [Bool]) async {
        var o = Single.just(())
        for (i, isChecked) in rows.enumerated() {
            guard isChecked else {continue}
            let item = vm.arrWords[i]
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
