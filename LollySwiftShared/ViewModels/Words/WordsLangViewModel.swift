//
//  WordsLangViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class WordsLangViewModel: WordsBaseViewModel {
    @Published var arrWords = [MLangWord]()
    @Published var arrWordsFiltered = [MLangWord]()

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        super.init(settings: settings, needCopy: needCopy)

        $arrWords.didSet.combineLatest($textFilter.didSet, $scopeFilter.didSet).sink { [unowned self] _ in
            arrWordsFiltered = arrWords
            if !textFilter.isEmpty {
                arrWordsFiltered = arrWordsFiltered.filter { (scopeFilter == "Word" ? $0.WORD : $0.NOTE).lowercased().contains(textFilter.lowercased()) }
            }
        } ~ subscriptions

        Task {
            await reload()
            complete()
        }
    }

    func reload() async {
        arrWords = await MLangWord.getDataByLang(vmSettings.selectedTextbook.LANGID)
    }

    static func update(item: MLangWord) async {
        await MLangWord.update(item: item)
    }

    static func create(item: MLangWord) async {
        item.ID = await MLangWord.create(item: item)
    }

    static func delete(item: MLangWord) async {
        await MLangWord.delete(item: item)
    }

    func newLangWord() -> MLangWord {
        MLangWord().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }

    func getNote(index: Int) async {
        let item = arrWords[index]
        let note = await vmSettings.getNote(word: item.WORD)
        item.NOTE = note
        await MLangWord.update(item.ID, note: note)
    }

    func clearNote(index: Int) async {
        let item = arrWords[index]
        item.NOTE = SettingsViewModel.zeroNote
        await WordsUnitViewModel.update(item.ID, note: item.NOTE)
    }

    public init(settings: SettingsViewModel) {
        super.init(settings: settings, needCopy: false)
    }

    func getWords(phraseid: Int) async {
        arrWords = await MWordPhrase.getWordsByPhraseId(phraseid)
    }
}
