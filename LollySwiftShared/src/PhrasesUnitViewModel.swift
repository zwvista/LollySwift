//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class PhrasesUnitViewModel: NSObject {
    open var settings: SettingsViewModel
    open var arrPhrases = [MUnitPhrase]()
    open var arrPhrasesFiltered: [MUnitPhrase]?
    
    public init(settings: SettingsViewModel, complete: (() -> Void)? = nil) {
        self.settings = settings
        super.init()
        MUnitPhrase.getDataByTextbook(settings.USTEXTBOOKID, unitPartFrom: settings.USUNITPARTFROM, unitPartTo: settings.USUNITPARTTO) { [unowned self] in self.arrPhrases = $0; complete?() }
    }
    
    open func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter { m in
            (scope == "Phrase" ? m.PHRASE! : m.TRANSLATION!).contains(searchText)
        }
    }
    
}
