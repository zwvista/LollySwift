//
//  WordsTextbookViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class WordsTextbookViewModel: NSObject {
    public var settings: SettingsViewModel
    public var arrWords: [MTextbookWord]
    public var arrWordsFiltered: [MTextbookWord]?
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrTextbooks[settings.currentTextbookIndex]
        arrWords = MTextbookWord.getDataByLang(m.LANGID)
    }
    
    public func filterWordsForSearchText(searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (m) -> Bool in
            return m.WORD!.containsString(searchText)
        })
    }

}
