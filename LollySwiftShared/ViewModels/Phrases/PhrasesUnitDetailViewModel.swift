//
//  PhrasesUnitDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

@MainActor
class PhrasesUnitDetailViewModel: NSObject, ObservableObject {
    var vm: PhrasesUnitViewModel
    var item: MUnitPhrase
    var wordid: Int
    var itemEdit: MUnitPhraseEdit
    var vmSingle: SinglePhraseViewModel
    var isAdd: Bool
    @Published var isOKEnabled = false

    init(vm: PhrasesUnitViewModel, item: MUnitPhrase, wordid: Int) {
        self.vm = vm
        self.item = item
        self.wordid = wordid
        itemEdit = MUnitPhraseEdit(x: item)
        isAdd = item.ID == 0
        vmSingle = SinglePhraseViewModel(phrase: isAdd ? "" : item.PHRASE)
        super.init()
        itemEdit.$PHRASE.map { !$0.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: item)
        item.PHRASE = vmSettings.autoCorrectInput(text: item.PHRASE)
        !isAdd ? await vm.update(item: item) : await vm.create(item: item)
        if wordid != 0 {
            await MWordPhrase.associate(wordid: wordid, phraseid: item.PHRASEID)
        }
    }
}
