//
//  WordsBookViewModel.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class WordsBookViewModel: NSObject {
    public var settings: SettingsViewModel
    public var arrWords: [MTBWord]
    public var arrWordsFiltered: [MTBWord]?
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrBooks[settings.currentBookIndex]
        arrWords = MTBWord.getDataByLang(m.LANGID)
    }
    
    public func filterWordsForSearchText(searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (m) -> Bool in
            return m.WORD!.containsString(searchText)
        })
    }

}
