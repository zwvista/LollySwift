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
        let item = settings.selectedTextbook!
        super.init()
        MLangPhrase.getDataByLang(item.LANGID).subscribe(onNext: {
            self.arrPhrases = $0
            complete()
        }).disposed(by: disposeBag)
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
        return MLangPhrase.update(item: item)
    }

    static func create(item: MLangPhrase) -> Observable<Int> {
        return MLangPhrase.create(item: item)
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // TODO check before deletion
        return MLangPhrase.delete(id)
    }

    func newLangPhrase() -> MLangPhrase {
        let item = MLangPhrase()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }

}
