//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

open class SettingsViewModel: NSObject {
    open var arrUserSettings = [MUserSetting]()
    open private(set) var USLANDID = 0
    open private(set) var USTEXTBOOKID = 0
    open private(set) var USDICTID = 0
    open var USUNITFROM = 0
    open var USUNITTO = 0
    open var USPARTFROM = 0
    open var USPARTTO = 0
    open var USUNITPARTFROM: Int {
        return USUNITFROM * 10 + USPARTFROM
    }
    open var USUNITPARTTO: Int {
        return USUNITTO * 10 + USPARTTO
    }
    open var isSingleUnitPart: Bool {
        return USUNITPARTFROM == USUNITPARTTO
    }

    open var arrLanguages = [MLanguage]()
    open private(set) var selectedLangIndex = 0
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
    
    public init(complete: (() -> Void)? = nil) {
        super.init()
        MLanguage.getData {
            self.arrLanguages = $0
            MUserSetting.getData {
                self.arrUserSettings = $0
                self.USLANDID = self.arrUserSettings.filter { $0.KIND == 1 }.first!.VALUE1!.toInt()!
                self.setSelectedLangIndex(self.arrLanguages.index { $0.ID! == self.USLANDID }!, complete: complete)
            }
        }
    }
    
    open func setSelectedLangIndex(_ langindex: Int, complete: (() -> Void)? = nil) {
        selectedLangIndex = langindex
        MDictionary.getDataByLang(self.USLANDID) {
            self.arrDictionaries = $0
            let m = self.arrUserSettings.filter { $0.KIND == 2 && $0.ENTITYID == self.USLANDID }.first!
            self.USTEXTBOOKID = m.VALUE1!.toInt()!
            self.USDICTID = m.VALUE2!.toInt()!
            self.selectedDictIndex = self.arrDictionaries.index { $0.ID! == self.USDICTID }!
            MTextbook.getDataByLang(self.USLANDID) {
                self.arrTextbooks = $0
                let m2 = self.arrUserSettings.filter { $0.KIND == 3 && $0.ENTITYID == self.USTEXTBOOKID }.first!
                self.USUNITFROM = m2.VALUE1!.toInt()!
                self.USPARTFROM = m2.VALUE2!.toInt()!
                self.USUNITTO = m2.VALUE3!.toInt()!
                self.USPARTTO = m2.VALUE4!.toInt()!
                self.selectedTextbookIndex = self.arrTextbooks.index { $0.ID! == self.USTEXTBOOKID }!
                complete?()
            }
        }
    }
    
    private func setSelectedTextbookIndex() {
        arrUnits = (1...selectedTextbook.UNITS!).map{ String($0) }
        arrParts = (selectedTextbook.PARTS?.components(separatedBy: " "))!
    }
}
