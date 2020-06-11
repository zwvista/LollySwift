//
//  PhrasesLangViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesLangViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPhrases = [MLangPhrase]()
    var arrPhrasesFiltered: [MLangPhrase]?
    
    public init(settings: SettingsViewModel, disposeBag: DisposeBag, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        reload().subscribe { complete() }.disposed(by: disposeBag)
    }
    
    func reload() -> Observable<()> {
        MLangPhrase.getDataByLang(vmSettings.selectedTextbook!.LANGID).map {
            self.arrPhrases = $0
        }
    }

    func applyFilters(textFilter: String, scope: String) {
        if textFilter.isEmpty {
            arrPhrasesFiltered = nil
        } else {
            arrPhrasesFiltered = arrPhrases
            if !textFilter.isEmpty {
                arrPhrasesFiltered = arrPhrasesFiltered!.filter { (scope == "Phrase" ? $0.PHRASE : $0.TRANSLATION ?? "").lowercased().contains(textFilter.lowercased()) }
            }
        }
    }
    
    static func update(item: MLangPhrase) -> Observable<()> {
        MLangPhrase.update(item: item)
    }

    static func create(item: MLangPhrase) -> Observable<Int> {
        MLangPhrase.create(item: item)
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        Observable.zip(MLangPhrase.delete(id), MUnitPhrase.deleteByPhraseId(id), MWordPhrase.deleteByPhraseId(id), MPatternPhrase.deleteByPhraseId(id)).map {_ in }
    }

    func newLangPhrase() -> MLangPhrase {
        let item = MLangPhrase()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }

}
