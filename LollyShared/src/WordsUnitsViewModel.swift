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
    public var arrWords: [MWordUnit]
    public var arrWordsFiltered: [MWordUnit]?
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrBooks[settings.currentBookIndex]
        arrWords = MWordUnit.getDataByBook(m.BOOKID, unitPartFrom: m.UNITFROM * 10 + m.PARTFROM, unitPartTo: m.UNITTO * 10 + m.PARTTO)
    }
    
    public func filterWordsForSearchText(searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (m) -> Bool in
            return m.WORD!.containsString(searchText)
        })
    }

}
