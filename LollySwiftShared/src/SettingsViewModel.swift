//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

open class SettingsViewModel: NSObject {
    open var arrLanguages: [MLanguage]
    open var selectedLangIndex: Int {
        didSet {
            setSelectedLangIndex()
        }
    }
    open var selectedLang: MLanguage {
        return arrLanguages[selectedLangIndex]
    }
    
    open var arrDictionaries = [MDictionary]()
    open var selectedDictIndex = 0
    open var selectedDict: MDictionary {
        return arrDictionaries[selectedDictIndex]
    }
    
    open var arrTextbooks = [MTextbook]()
    open var selectedTextbookIndex: Int {
        didSet {
            setSelectedTextbookIndex()
        }
    }
    open var selectedTextbook: MTextbook {
        return arrTextbooks[selectedTextbookIndex]
    }
    
    open var arrUnits = [String]()
    open var arrParts = [String]()
    
    public override init() {
        arrLanguages = MLanguage.getData()
        let m = MUserSetting.getData()[0]
        selectedLangIndex = arrLanguages.index{ $0.ID == m.USLANGID }!
        selectedTextbookIndex = 0
        super.init()
        setSelectedLangIndex()
    }
    
    fileprivate func setSelectedLangIndex() {
        let m = arrLanguages[selectedLangIndex]
        arrDictionaries = MDictionary.getDataByLang(m.ID)
        selectedDictIndex = arrDictionaries.index{ $0.ID == m.USDICTID }!
        arrTextbooks = MTextbook.getDataByLang(m.ID)
        selectedTextbookIndex = arrTextbooks.index{ $0.ID == m.USTEXTBOOKID }!
    }
    
    fileprivate func setSelectedTextbookIndex() {
        arrUnits = (1 ... selectedTextbook.UNITS).map{ String($0) }
        arrParts = (selectedTextbook.PARTS?.components(separatedBy: " "))!
    }
}
