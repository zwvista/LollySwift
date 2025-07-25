//
//  WordsLangDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

@MainActor
class WordsLangDetailViewModel: NSObject, ObservableObject {
    var vm: WordsLangViewModel
    var item: MLangWord
    var itemEdit: MLangWordEdit
    var vmSingle: SingleWordViewModel
    var isAdd: Bool
    @Published var isOKEnabled = false

    init(vm: WordsLangViewModel, item: MLangWord) {
        self.vm = vm
        self.item = item
        itemEdit = MLangWordEdit(x: item)
        isAdd = item.ID == 0
        vmSingle = SingleWordViewModel(word: isAdd ? "" : item.WORD, settings: vm.vmSettings)
        super.init()
        itemEdit.$WORD.map { !$0.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: item)
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        if isAdd {
            vm.arrWordsAll.append(item)
            await WordsLangViewModel.create(item: item)
        } else {
            await WordsLangViewModel.update(item: item)
        }
    }
}
