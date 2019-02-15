//
//  PhrasesTextbookViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesTextbookViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPhrases = [MTextbookPhrase]()
    var arrPhrasesFiltered: [MTextbookPhrase]?

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        self.vmSettings = settings
        let item = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MTextbookPhrase.getDataByLang(item.LANGID).subscribe(onNext: {
            self.arrPhrases = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (item) -> Bool in
            return (scope == "Phrase" ? item.PHRASE : item.TRANSLATION ?? "").contains(searchText)
        })
    }

    static func update(item: MTextbookPhrase) -> Observable<String> {
        let item = MLangPhrase(textbookitem: item)
        return MLangPhrase.update(item: item)
    }
}
