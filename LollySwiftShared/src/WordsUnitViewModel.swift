//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

open class WordsUnitViewModel: NSObject {
    open var settings: SettingsViewModel
    open var arrWords = [MUnitWord]()
    open var arrWordsFiltered: [MUnitWord]?
    
    public init(settings: SettingsViewModel, completionHandler: (() -> Void)? = nil) {
        self.settings = settings
        let m = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MUnitWord.getDataByTextbook(m.ID!, unitPartFrom: m.USUNITFROM * 10 + m.USPARTFROM, unitPartTo: m.USUNITTO * 10 + m.USPARTTO) { [unowned self] in self.arrWords = $0; completionHandler?() }
    }
    
    open func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (m) -> Bool in
            return m.WORD!.contains(searchText)
        })
    }

}
