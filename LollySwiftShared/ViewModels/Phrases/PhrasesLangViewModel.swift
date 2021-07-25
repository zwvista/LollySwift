//
//  PhrasesLangViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import Then

class PhrasesLangViewModel: PhrasesBaseViewModel {
    var arrPhrases = [MLangPhrase]()
    var arrPhrasesFiltered: [MLangPhrase]?

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        super.init(settings: settings, needCopy: needCopy)
        reload().subscribe(onCompleted: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Completable {
        MLangPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID).flatMapCompletable {
            self.arrPhrases = $0
            return Completable.empty()
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
    
    static func update(item: MLangPhrase) -> Completable {
        MLangPhrase.update(item: item)
    }

    static func create(item: MLangPhrase) -> Completable {
        MLangPhrase.create(item: item).flatMapCompletable {
            item.ID = $0
            return Completable.empty()
        }
    }
    
    static func delete(item: MLangPhrase) -> Completable {
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
    
    func getPhrases(wordid: Int) -> Completable {
        MWordPhrase.getPhrasesByWordId(wordid).flatMapCompletable {
            self.arrPhrases = $0
            return Completable.empty()
        }
    }
}
