//
//  WordsLangViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class WordsLangViewModel: WordsBaseViewModel {
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        super.init(settings: settings, needCopy: needCopy)
        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        MLangWord.getDataByLang(vmSettings.selectedTextbook.LANGID).map {
            self.arrWords = $0
        }
    }

    func applyFilters() {
        if textFilter.isEmpty {
            arrWordsFiltered = nil
        } else {
            arrWordsFiltered = arrWords
            if !textFilter.isEmpty {
                arrWordsFiltered = arrWordsFiltered!.filter { (scopeFilter == "Word" ? $0.WORD : $0.NOTE).lowercased().contains(textFilter.lowercased()) }
            }
        }
    }

    static func update(item: MLangWord) -> Single<()> {
        MLangWord.update(item: item)
    }

    static func create(item: MLangWord) -> Single<()> {
        MLangWord.create(item: item).map {
            item.ID = $0
        }
    }

    static func delete(item: MLangWord) -> Single<()> {
        MLangWord.delete(item: item)
    }

    func newLangWord() -> MLangWord {
        MLangWord().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }

    func getNote(index: Int) -> Single<()> {
        let item = arrWords[index]
        return vmSettings.getNote(word: item.WORD).flatMap { note in
            item.NOTE = note
            return MLangWord.update(item.ID, note: note)
        }
    }

    func clearNote(index: Int) -> Single<()> {
        let item = arrWords[index]
        item.NOTE = SettingsViewModel.zeroNote
        return WordsUnitViewModel.update(item.ID, note: item.NOTE)
    }

    public init(settings: SettingsViewModel) {
        super.init(settings: settings, needCopy: false)
    }

    func getWords(phraseid: Int) -> Single<()> {
        MWordPhrase.getWordsByPhraseId(phraseid).map {
            self.arrWords = $0
        }
    }
}
