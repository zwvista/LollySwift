//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class WordsUnitViewModel: NSObject {
    var settings: SettingsViewModel
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?
    
    public init(settings: SettingsViewModel, complete: (() -> Void)? = nil) {
        self.settings = settings
        super.init()
        MUnitWord.getDataByTextbook(settings.USTEXTBOOKID, unitPartFrom: settings.USUNITPARTFROM, unitPartTo: settings.USUNITPARTTO) { [unowned self] in self.arrWords = $0; complete?() }
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter { $0.WORD!.contains(searchText) }
    }

}
