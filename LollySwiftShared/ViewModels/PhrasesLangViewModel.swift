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
    
    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        self.vmSettings = settings
        let item = settings.selectedTextbook!
        super.init()
        MLangPhrase.getDataByLang(item.LANGID).subscribe(onNext: {
            self.arrPhrases = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (item) -> Bool in
            return (scope == "Phrase" ? item.PHRASE : item.TRANSLATION ?? "").contains(searchText)
        })
    }
    
    static func update(_ id: Int, item: MLangPhrase) -> Observable<()> {
        return MLangPhrase.update(id, item: item).map { print($0) }
    }
    
    static func update(item: MLangPhrase) -> Observable<()> {
        return MLangPhrase.update(item: item).map { print($0) }
    }

    static func create(item: MLangPhrase) -> Observable<Int> {
        return MLangPhrase.create(item: item).map { print($0); return $0 }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MLangPhrase.delete(id).map { print($0) }
    }

    func newLangPhrase() -> MLangPhrase {
        let item = MLangPhrase()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }

}
