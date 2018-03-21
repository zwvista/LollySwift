//
//  WordsLangViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class WordsLangViewModel: NSObject {
    var settings: SettingsViewModel
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?
    
    public init(settings: SettingsViewModel, complete: (() -> Void)? = nil) {
        self.settings = settings
        let m = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MLangWord.getDataByLang(m.LANGID) {[unowned self] in self.arrWords = $0; complete?() }
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (m) -> Bool in
            return m.WORD!.contains(searchText)
        })
    }

}
