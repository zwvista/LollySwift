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
    
    public init(settings: SettingsViewModel, completionHandler: (() -> Void)? = nil) {
        self.settings = settings
        let m = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MUnitPhrase.getDataByTextbook(m.ID!, unitPartFrom: m.USUNITFROM * 10 + m.USPARTFROM, unitPartTo: m.USUNITTO * 10 + m.USPARTTO) { [unowned self] in self.arrPhrases = $0; completionHandler?() }
    }
    
    open func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (m) -> Bool in
            return (scope == "Phrase" ? m.PHRASE! : m.TRANSLATION!).contains(searchText)
        })
    }
    
}
