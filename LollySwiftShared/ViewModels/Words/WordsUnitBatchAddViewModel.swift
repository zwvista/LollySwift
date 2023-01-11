//
//  WordsUnitBatchAddViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation

@MainActor
class WordsUnitBatchAddViewModel: NSObject, ObservableObject {
    var vm: WordsUnitViewModel
    var item: MUnitWord!
    var itemEdit: MUnitWordEdit
    @Published var isOKEnabled = false

    init(vm: WordsUnitViewModel) {
        self.vm = vm
        item = vm.newUnitWord()
        itemEdit = MUnitWordEdit(x: item)
    }

    func onOK() async {
        itemEdit.save(to: item)
        let words = itemEdit.WORDS.split(separator: "\n")
        for s in words {
            let item2 = MUnitWord()
            copyProperties(from: item, to: item2)
            item2.WORD = vm.vmSettings.autoCorrectInput(text: String(s))
            await vm.create(item: item2)
            item.SEQNUM += 1
        }
    }
}
