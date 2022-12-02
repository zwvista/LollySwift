//
//  WordsUnitDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

class WordsUnitDetailViewModel: NSObject, ObservableObject {
    var vm: WordsUnitViewModel!
    var item: MUnitWord!
    var phraseid: Int
    var itemEdit: MUnitWordEdit!
    var vmSingle: SingleWordViewModel!
    var isAdd: Bool!
    @Published var isOKEnabled = false

    init(vm: WordsUnitViewModel, item: MUnitWord, phraseid: Int, complete: @escaping () -> Void) {
        self.vm = vm
        self.item = item
        self.phraseid = phraseid
        itemEdit = MUnitWordEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.WORD.map { !$0.isEmpty } ~> isOKEnabled
        guard !isAdd else {return}
        vmSingle = SingleWordViewModel(word: item.WORD, settings: vm.vmSettings, complete: complete)
    }
    
    func onOK() async {
        itemEdit.save(to: item)
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        return !isAdd ? vm.update(item: item) : vm.create(item: item).flatMap {
            self.phraseid == 0 ? Single.just(()) : MWordPhrase.associate(wordid: self.item.WORDID, phraseid: self.phraseid)
        }
    }
}
