//
//  WordsTextbookViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class WordsTextbookViewModel: NSObject {
    open var settings: SettingsViewModel
    open var arrWords: [MTextbookWord]
    open var arrWordsFiltered: [MTextbookWord]?
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrTextbooks[settings.selectedTextbookIndex]
        arrWords = MTextbookWord.getDataByLang(m.LANGID!)
    }
    
    open func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (m) -> Bool in
            return m.WORD!.contains(searchText)
        })
    }

}
