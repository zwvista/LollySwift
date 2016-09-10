//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

public class SettingsViewModel: NSObject {
    public var arrLanguages: [MLanguage]
    public var selectedLangIndex: Int {
        didSet {
            setSelectedLangIndex()
        }
    }
    public var selectedLang: MLanguage {
        return arrLanguages[selectedLangIndex]
    }
    
    public var arrDictionaries = [MDictionary]()
    public var selectedDictIndex = 0
    public var selectedDict: MDictionary {
        return arrDictionaries[selectedDictIndex]
    }
    
    public var arrTextbooks = [MTextbook]()
    public var selectedTextbookIndex: Int {
        didSet {
            setSelectedTextbookIndex()
        }
    }
    public var selectedTextbook: MTextbook {
        return arrTextbooks[selectedTextbookIndex]
    }
    
    public var arrUnits = [String]()
    public var arrParts = [String]()
    
    public override init() {
        arrLanguages = MLanguage.getData()
        let m = MUserSetting.getData()[0]
        selectedLangIndex = arrLanguages.indexOf{ $0.ID == m.USLANGID }!
        selectedTextbookIndex = 0
        super.init()
        setSelectedLangIndex()
    }
    
    private func setSelectedLangIndex() {
        let m = arrLanguages[selectedLangIndex]
        arrDictionaries = MDictionary.getDataByLang(m.ID)
        selectedDictIndex = arrDictionaries.indexOf{ $0.ID == m.USDICTID }!
        arrTextbooks = MTextbook.getDataByLang(m.ID)
        selectedTextbookIndex = arrTextbooks.indexOf{ $0.ID == m.USTEXTBOOKID }!
    }
    
    private func setSelectedTextbookIndex() {
        arrUnits = (1 ... selectedTextbook.UNITS).map{ String($0) }
        arrParts = (selectedTextbook.PARTS?.componentsSeparatedByString(" "))!
    }
}
