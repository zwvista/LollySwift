//
//  PhrasesLangViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding
import Then

class PhrasesLangViewModel: PhrasesBaseViewModel {
    var arrPhrases_ = BehaviorRelay(value: [MLangPhrase]())
    var arrPhrases: [MLangPhrase] { get { arrPhrases_.value } set { arrPhrases_.accept(newValue) } }
    var arrPhrasesFiltered_ = BehaviorRelay(value: [MLangPhrase]())
    var arrPhrasesFiltered: [MLangPhrase] { get { arrPhrasesFiltered_.value } set { arrPhrasesFiltered_.accept(newValue) } }
    var hasFilter: Bool { !textFilter.isEmpty }

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        super.init(settings: settings, needCopy: needCopy)

        Observable.combineLatest(arrPhrases_, textFilter_, scopeFilter_).subscribe { [unowned self] _ in
            arrPhrasesFiltered = arrPhrases
            if !textFilter.isEmpty {
                arrPhrasesFiltered = arrPhrasesFiltered.filter { (scopeFilter == "Phrase" ? $0.PHRASE : $0.TRANSLATION).lowercased().contains(textFilter.lowercased()) }
            }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        MLangPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID).map { [unowned self] in
            arrPhrases = $0
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
        MWordPhrase.getPhrasesByWordId(wordid).map { [unowned self] in
            arrPhrases = $0
        }
    }
}
