//
//  PhrasesLangViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class PhrasesLangViewModel: PhrasesBaseViewModel {
    @Published var arrPhrasesAll = [MLangPhrase]()
    @Published var arrPhrases = [MLangPhrase]()
    var hasFilter: Bool { !textFilter.isEmpty }

    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        super.init(settings: settings)

        $arrPhrasesAll.didSet.combineLatest($textFilter.didSet, $scopeFilter.didSet).sink { [unowned self] _ in
            arrPhrases = arrPhrasesAll
            if !textFilter.isEmpty {
                arrPhrases = arrPhrases.filter { (scopeFilter == "Phrase" ? $0.PHRASE : $0.TRANSLATION).lowercased().contains(textFilter.lowercased()) }
            }
        } ~ subscriptions

        Task {
            await reload()
            complete()
        }
    }

    func reload() async {
        arrPhrasesAll = await MLangPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID)
    }

    static func update(item: MLangPhrase) async {
        await MLangPhrase.update(item: item)
    }

    static func create(item: MLangPhrase) async {
        item.ID = await MLangPhrase.create(item: item)
    }

    static func delete(item: MLangPhrase) async {
        await MLangPhrase.delete(item: item)
    }

    func newLangPhrase() -> MLangPhrase {
        MLangPhrase().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }

    func getPhrases(wordid: Int) async {
        arrPhrasesAll = await MWordPhrase.getPhrasesByWordId(wordid)
    }
}
