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
    var arrPhrasesAll_ = BehaviorRelay(value: [MLangPhrase]())
    var arrPhrasesAll: [MLangPhrase] { get { arrPhrasesAll_.value } set { arrPhrasesAll_.accept(newValue) } }
    var arrPhrases_ = BehaviorRelay(value: [MLangPhrase]())
    var arrPhrases: [MLangPhrase] { get { arrPhrases_.value } set { arrPhrases_.accept(newValue) } }
    var hasFilter: Bool { !textFilter.isEmpty }

    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        super.init(settings: settings)

        Observable.combineLatest(arrPhrasesAll_, textFilter_, scopeFilter_).subscribe { [unowned self] _ in
            arrPhrases = arrPhrasesAll
            if !textFilter.isEmpty {
                arrPhrases = arrPhrases.filter { (scopeFilter == "Phrase" ? $0.PHRASE : $0.TRANSLATION).lowercased().contains(textFilter.lowercased()) }
            }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        MLangPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID).map { [unowned self] in
            arrPhrasesAll = $0
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

    func getPhrases(wordid: Int) -> Single<()> {
        MWordPhrase.getPhrasesByWordId(wordid).map { [unowned self] in
            arrPhrasesAll = $0
        }
    }
}
