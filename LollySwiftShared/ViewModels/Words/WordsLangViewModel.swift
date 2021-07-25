//
//  WordsLangViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import Then

class WordsLangViewModel: WordsBaseViewModel {
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        super.init(settings: settings, needCopy: needCopy)
        reload().subscribe(onCompleted: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Completable {
        MLangWord.getDataByLang(vmSettings.selectedTextbook.LANGID).flatMapCompletable {
            self.arrWords = $0
            return Completable.empty()
        }
    }
    
    func applyFilters() {
        if textFilter.value.isEmpty {
            arrWordsFiltered = nil
        } else {
            arrWordsFiltered = arrWords
            if !textFilter.value.isEmpty {
                arrWordsFiltered = arrWordsFiltered!.filter { (scopeFilter.value == "Word" ? $0.WORD : $0.NOTE).lowercased().contains(textFilter.value.lowercased()) }
            }
        }
    }
    
    static func update(item: MLangWord) -> Completable {
        MLangWord.update(item: item)
    }

    static func create(item: MLangWord) -> Completable {
        MLangWord.create(item: item).flatMapCompletable {
            item.ID = $0
            return Completable.empty()
        }
    }
    
    static func delete(item: MLangWord) -> Completable {
        MLangWord.delete(item: item)
    }
    
    func newLangWord() -> MLangWord {
        MLangWord().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }

    func getNote(index: Int) -> Completable {
        let item = arrWords[index]
        return vmSettings.getNote(word: item.WORD).flatMapCompletable { note in
            item.NOTE = note
            return MLangWord.update(item.ID, note: note)
        }
    }

    func clearNote(index: Int) -> Completable {
        let item = arrWords[index]
        item.NOTE = SettingsViewModel.zeroNote
        return WordsUnitViewModel.update(item.ID, note: item.NOTE)
    }
    
    public init(settings: SettingsViewModel) {
        super.init(settings: settings, needCopy: false)
    }
    
    func getWords(phraseid: Int) -> Completable {
        MWordPhrase.getWordsByPhraseId(phraseid).flatMapCompletable {
            self.arrWords = $0
            return Completable.empty()
        }
    }
}
