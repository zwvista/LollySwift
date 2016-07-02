//
//  WordsViewModel.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class WordsViewModel: NSObject {
    public var settings: SettingsViewModel
    public var arrWords: [MWordUnit]
    
    public init(settings: SettingsViewModel) {
        self.settings = settings
        let m = settings.arrBooks[settings.currentBookIndex]
        arrWords = MWordUnit.getDataByBookUnitParts(m.BOOKID, unitpartfrom: m.UNITFROM * 10 + m.PARTFROM, unitpartto: m.UNITTO * 10 + m.PARTTO)
    }

}
