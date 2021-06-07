//
//  WordsLangViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsLangViewModel: WordsBaseViewModel {
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        super.init(settings: settings, needCopy: needCopy)
        reload().subscribe(onNext: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Observable<()> {
        MLangWord.getDataByLang(vmSettings.selectedTextbook.LANGID).map {
            self.arrWords = $0
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
    
    static func update(item: MLangWord) -> Observable<()> {
        MLangWord.update(item: item)
    }

    static func create(item: MLangWord) -> Observable<()> {
        MLangWord.create(item: item).map {
            item.ID = $0
        }
    }
    
    static func delete(item: MLangWord) -> Observable<()> {
        MLangWord.delete(item: item)
    }
    
    func newLangWord() -> MLangWord {
        let item = MLangWord()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }

    func getNote(index: Int) -> Observable<()> {
        let item = arrWords[index]
        return vmSettings.getNote(word: item.WORD).flatMap { note -> Observable<()> in
            item.NOTE = note
            return MLangWord.update(item.ID, note: note)
        }
    }

    func clearNote(index: Int) -> Observable<()> {
        let item = arrWords[index]
        item.NOTE = SettingsViewModel.zeroNote
        return WordsUnitViewModel.update(item.ID, note: item.NOTE)
    }
    
    public init(settings: SettingsViewModel) {
        super.init(settings: settings, needCopy: false)
    }
    
    func getWords(phraseid: Int) -> Observable<()> {
        MWordPhrase.getWordsByPhraseId(phraseid).map {
            self.arrWords = $0
        }
    }
}
