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
    
    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        reload().subscribe { complete() } ~ rx.disposeBag
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
    
    static func delete(item: MLangPhrase) -> Observable<()> {
        MLangPhrase.delete(item: item)
    }

    func newLangPhrase() -> MLangPhrase {
        let item = MLangPhrase()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }

}
