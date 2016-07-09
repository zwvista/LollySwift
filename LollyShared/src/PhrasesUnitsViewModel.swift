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
    public var arrPhrases: [MPhraseUnit]
    public var arrPhrasesFiltered: [MPhraseUnit]?
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrBooks[settings.currentBookIndex]
        arrPhrases = MPhraseUnit.getDataByBook(m.BOOKID, unitPartFrom: m.UNITFROM * 10 + m.PARTFROM, unitPartTo: m.UNITTO * 10 + m.PARTTO)
    }
    
    public func filterPhrasesForSearchText(searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (m) -> Bool in
            return m.PHRASE!.containsString(searchText)
        })
    }
    
}
