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
    
    public var arrTextbooks = [MTextbook]()
    public var currentTextbookIndex: Int {
        didSet {
            setCurrentTextbookIndex()
        }
    }
    public var currentTextbook: MTextbook {
        return arrTextbooks[currentTextbookIndex]
    }
    
    public var arrUnits = [String]()
    public var arrParts = [String]()
    
    public override init() {
        arrLanguages = MLanguage.getData()
        let m = MUserSetting.getData()[0]
        currentLangIndex = arrLanguages.indexOf{ $0.ID == m.USLANGID }!
        currentTextbookIndex = 0
        super.init()
        setCurrentLangIndex()
    }
    
    private func setCurrentLangIndex() {
        let m = arrLanguages[currentLangIndex]
        arrDictionaries = MDictionary.getDataByLang(m.ID)
        currentDictIndex = arrDictionaries.indexOf{ $0.ID == m.USDICTID }!
        arrTextbooks = MTextbook.getDataByLang(m.ID)
        currentTextbookIndex = arrTextbooks.indexOf{ $0.ID == m.USTEXTBOOKID }!
    }
    
    private func setCurrentTextbookIndex() {
        arrUnits = (1 ... currentTextbook.UNITS).map{ String($0) }
        arrParts = (currentTextbook.PARTS?.componentsSeparatedByString(" "))!
    }
}
