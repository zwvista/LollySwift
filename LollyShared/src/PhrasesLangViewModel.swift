//
//  PhrasesLangViewModel.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class PhrasesLangViewModel: NSObject {
    public var settings: SettingsViewModel
    public var arrPhrases: [MPhraseLang]
    public var arrPhrasesFiltered: [MPhraseLang]?
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrBooks[settings.currentBookIndex]
        arrPhrases = MPhraseLang.getDataByLang(m.LANGID)
    }
    
    public func filterPhrasesForSearchText(searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (m) -> Bool in
            return m.PHRASE!.containsString(searchText)
        })
    }

}
