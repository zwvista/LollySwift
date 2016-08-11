//
//  WordsUnitsViewModel.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class WordsUnitsViewModel: NSObject {
    public var settings: SettingsViewModel
    public var arrWords: [MUnitWord]
    public var arrWordsFiltered: [MUnitWord]?
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrTextBooks[settings.currentTextBookIndex]
        arrWords = MUnitWord.getDataByTextBook(m.ID, unitPartFrom: m.USUNITFROM * 10 + m.USPARTFROM, unitPartTo: m.USUNITTO * 10 + m.USPARTTO)
    }
    
    public func filterWordsForSearchText(searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (m) -> Bool in
            return m.WORD!.containsString(searchText)
        })
    }

}
