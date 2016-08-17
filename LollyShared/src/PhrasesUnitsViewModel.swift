//
//  PhrasesUnitsViewModel.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class PhrasesUnitsViewModel: NSObject {
    public var settings: SettingsViewModel
    public var arrPhrases: [MUnitPhrase]
    public var arrPhrasesFiltered: [MUnitPhrase]?
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrTextBooks[settings.currentTextBookIndex]
        arrPhrases = MUnitPhrase.getDataByTextBook(m.ID, unitPartFrom: m.USUNITFROM * 10 + m.USPARTFROM, unitPartTo: m.USUNITTO * 10 + m.USPARTTO)
    }
    
    public func filterPhrasesForSearchText(searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (m) -> Bool in
            return (scope == "Phrase" ? m.PHRASE! : m.TRANSLATION!).containsString(searchText)
        })
    }
    
}