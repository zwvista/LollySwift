//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

open class SettingsViewModel: NSObject {
    open var arrLanguages = [MLanguage]()
    open var selectedLangIndex = 0 {
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
    open var selectedTextbookIndex = 0 {
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
        super.init()
        MLanguage.getData() { [unowned self] in
            self.arrLanguages = $0
            MUserSetting.getData() { [unowned self] in
                let m = $0[0]
                self.selectedLangIndex = self.arrLanguages.index{ String($0.ID!) == m.USLANGID }!
                self.setSelectedLangIndex()
            }
        }
    }
    
    fileprivate func setSelectedLangIndex() {
        let m = arrLanguages[selectedLangIndex]
        MDictionary.getDataByLang(m.ID!) { [unowned self] in
            self.arrDictionaries = $0
            self.selectedDictIndex = self.arrDictionaries.index{ String($0.ID!) == m.USDICTID }!
            MTextbook.getDataByLang(m.ID!) { [unowned self] in
                self.arrTextbooks = $0
                self.selectedTextbookIndex = self.arrTextbooks.index{ String($0.ID!) == m.USTEXTBOOKID }!
            }
        }
    }
    
    fileprivate func setSelectedTextbookIndex() {
        arrUnits = (1...selectedTextbook.UNITS!).map{ String($0) }
        arrParts = (selectedTextbook.PARTS?.components(separatedBy: " "))!
    }
}
