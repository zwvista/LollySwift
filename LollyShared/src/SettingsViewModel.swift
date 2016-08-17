//
//  SettingsViewModel.swift
//  LollyShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class SettingsViewModel: NSObject {
    public var arrLanguages: [MLanguage]
    public var currentLangIndex: Int {
        didSet {
            setCurrentLangIndex()
        }
    }
    public var currentLang: MLanguage {
        return arrLanguages[currentLangIndex]
    }
    
    public var arrDictionaries = [MDictionary]()
    public var currentDictIndex = 0
    public var currentDict: MDictionary {
        return arrDictionaries[currentDictIndex]
    }
    
    public var arrTextBooks = [MTextBook]()
    public var currentTextBookIndex = 0
    public var currentTextBook: MTextBook {
        return arrTextBooks[currentTextBookIndex]
    }
    
    public override init() {
        arrLanguages = MLanguage.getData()
        let langid = MUserSetting.getData()[0].USLANGID
        currentLangIndex = arrLanguages.indexOf{ $0.ID == langid }!
        super.init()
        setCurrentLangIndex()
    }
    
    private func setCurrentLangIndex() {
        let m = arrLanguages[currentLangIndex]
        arrDictionaries = MDictionary.getDataByLang(m.ID)
        currentDictIndex = arrDictionaries.indexOf{ $0.ID == m.USDICTID }!
        arrTextBooks = MTextBook.getDataByLang(m.ID)
        currentTextBookIndex = arrTextBooks.indexOf{ $0.ID == m.USTEXTBOOKID }!
    }
}
