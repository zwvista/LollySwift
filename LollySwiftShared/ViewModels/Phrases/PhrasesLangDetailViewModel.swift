//
//  PhrasesLangDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

@MainActor
class PhrasesLangDetailViewModel: NSObject, ObservableObject {
    var vm: PhrasesLangViewModel
    var item: MLangPhrase
    var itemEdit: MLangPhraseEdit
    var vmSingle: SinglePhraseViewModel
    var isAdd: Bool
    @Published var isOKEnabled = false

    init(vm: PhrasesLangViewModel, item: MLangPhrase) {
        self.vm = vm
        self.item = item
        itemEdit = MLangPhraseEdit(x: item)
        isAdd = item.ID == 0
        vmSingle = SinglePhraseViewModel(phrase: isAdd ? "" : item.PHRASE)
        super.init()
        itemEdit.$PHRASE.map { !$0.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: item)
        item.PHRASE = vmSettings.autoCorrectInput(text: item.PHRASE)
        if isAdd {
            vm.arrPhrasesAll.append(item)
            await PhrasesLangViewModel.create(item: item)
        } else {
            await PhrasesLangViewModel.update(item: item)
        }
    }
}
