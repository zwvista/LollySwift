//
//  PhrasesUnitBatchAddViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import Foundation

@MainActor
class PhrasesUnitBatchAddViewModel: NSObject, ObservableObject {
    var vm: PhrasesUnitViewModel
    var item: MUnitPhrase
    var itemEdit: MUnitPhraseEdit
    @Published var isOKEnabled = false

    init(vm: PhrasesUnitViewModel) {
        self.vm = vm
        item = vm.newUnitPhrase()
        itemEdit = MUnitPhraseEdit(x: item)
    }

    func onOK() async {
        itemEdit.save(to: item)
        let phrases = itemEdit.PHRASES.split(separator: "\n").map { String($0) }
        for i in stride(from: 0, to: phrases.count, by: 2) {
            let item2 = MUnitPhrase()
            copyProperties(from: item, to: item2)
            item2.PHRASE = vm.vmSettings.autoCorrectInput(text: phrases[i])
            item2.TRANSLATION = phrases[i + 1]
            await vm.create(item: item2)
            item.SEQNUM += 1
        }
    }
}
