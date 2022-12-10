//
//  WordsUnitBatchEditViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation

@MainActor
class WordsUnitBatchEditViewModel: NSObject, ObservableObject {
    var vm: WordsUnitViewModel!
    @Published var isOKEnabled = false

    @Published var indexUNIT = 0
    var UNIT: Int { vm.vmSettings.arrUnits[indexUNIT].value }
    @Published var indexPART = 0
    var PART: Int { vm.vmSettings.arrParts[indexPART].value }
    @Published var SEQNUM = ""
    @Published var unitChecked = false
    @Published var partChecked = false
    @Published var seqnumChecked = false

    init(vm: WordsUnitViewModel, unit: Int, part: Int) {
        self.vm = vm
        indexUNIT = vm.vmSettings.arrUnits.firstIndex { $0.value == unit }!
        indexPART = vm.vmSettings.arrParts.firstIndex { $0.value == part }!
    }
    
    func onOK(rows: [Bool]) async {
        for (i, isChecked) in rows.enumerated() {
            guard isChecked else {continue}
            let item = vm.arrWords[i]
            if unitChecked || partChecked || seqnumChecked {
                if unitChecked { item.UNIT = UNIT }
                if partChecked { item.PART = PART }
                if seqnumChecked { item.SEQNUM += Int(SEQNUM)! }
                await vm.update(item: item)
            }
        }
    }
}
