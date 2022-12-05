//
//  PhrasesLangViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class PhrasesLangViewModel: PhrasesBaseViewModel {
    var arrPhrases = [MLangPhrase]()
    var arrPhrasesFiltered: [MLangPhrase]?

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        super.init(settings: settings, needCopy: needCopy)
        reload().subscribe { complete() } ~ rx.disposeBag
    }
    
    func reload() -> Single<()> {
        MLangPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID).map {
            self.arrPhrases = $0
        }
    }

    func applyFilters() {
        if textFilter.value.isEmpty {
            arrPhrasesFiltered = nil
        } else {
            arrPhrasesFiltered = arrPhrases
            if !textFilter.value.isEmpty {
                arrPhrasesFiltered = arrPhrasesFiltered!.filter { (scopeFilter.value == "Phrase" ? $0.PHRASE : $0.TRANSLATION).lowercased().contains(textFilter.value.lowercased()) }
            }
        }
    }
    
    static func update(item: MLangPhrase) -> Single<()> {
        MLangPhrase.update(item: item)
    }

    static func create(item: MLangPhrase) -> Single<()> {
        MLangPhrase.create(item: item).map {
            item.ID = $0
        }
    }
    
    static func delete(item: MLangPhrase) -> Single<()> {
        MLangPhrase.delete(item: item)
    }

    func newLangPhrase() -> MLangPhrase {
        MLangPhrase().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
    
    public init(settings: SettingsViewModel) {
        super.init(settings: settings, needCopy: false)
    }
    
    func getPhrases(wordid: Int) -> Single<()> {
        MWordPhrase.getPhrasesByWordId(wordid).map {
            self.arrPhrases = $0
        }
    }
}
