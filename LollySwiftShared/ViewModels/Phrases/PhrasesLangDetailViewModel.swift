//
//  PhrasesLangDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

class PhrasesLangDetailViewModel: NSObject, ObservableObject {
    var vm: PhrasesLangViewModel!
    var item: MLangPhrase!
    var itemEdit: MLangPhraseEdit!
    var vmSingle: SinglePhraseViewModel!
    var isAdd: Bool!
    @Published var isOKEnabled = false

    init(vm: PhrasesLangViewModel, item: MLangPhrase, complete: @escaping () -> Void) {
        self.vm = vm
        self.item = item
        itemEdit = MLangPhraseEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.PHRASE.map { !$0.isEmpty } ~> isOKEnabled
        guard !isAdd else {return}
        vmSingle = SinglePhraseViewModel(phrase: item.PHRASE, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() async {
        itemEdit.save(to: item)
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        if isAdd {
            vm.arrPhrases.append(item)
            await PhrasesLangViewModel.create(item: item)
        } else {
            await PhrasesLangViewModel.update(item: item)
        }
    }
}
