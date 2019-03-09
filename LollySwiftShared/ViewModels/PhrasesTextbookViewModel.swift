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
    var arrPhrases = [MUnitPhrase]()
    var arrPhrasesFiltered: [MUnitPhrase]?

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        self.vmSettings = settings
        let item = settings.selectedTextbook!
        super.init()
        MUnitPhrase.getDataByLang(item.LANGID, arrTextbooks: vmSettings.arrTextbooks).subscribe(onNext: {
            self.arrPhrases = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (item) -> Bool in
            return (scope == "Phrase" ? item.PHRASE : item.TRANSLATION ?? "").contains(searchText)
        })
    }
}
