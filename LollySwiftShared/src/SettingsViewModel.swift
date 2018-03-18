//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation

open class SettingsViewModel: NSObject {
    
    let userid = 1

    open var arrUserSettings = [MUserSetting]()
    private var selectedUSUserIndex = 0
    open var selectedUSUser: MUserSetting {
        return arrUserSettings[selectedUSUserIndex]
    }
    open var USLANDID: Int {
        get { return selectedUSUser.VALUE1!.toInt()! }
        set { selectedUSUser.VALUE1 = String(newValue) }
    }
    private var selectedUSLangIndex = 0
    open var selectedUSLang: MUserSetting {
        return arrUserSettings[selectedUSLangIndex]
    }
    open var USTEXTBOOKID: Int {
        get { return selectedUSLang.VALUE1!.toInt()! }
        set { selectedUSLang.VALUE1 = String(newValue) }
    }
    open var USDICTID: Int {
        get { return selectedUSLang.VALUE2!.toInt()! }
        set { selectedUSLang.VALUE2 = String(newValue) }
    }
    private var selectedUSTextbookIndex = 0
    open var selectedUSTextbook: MUserSetting {
        return arrUserSettings[selectedUSTextbookIndex]
    }
    open var USUNITFROM: Int {
        get { return selectedUSTextbook.VALUE1!.toInt()! }
        set { selectedUSTextbook.VALUE1 = String(newValue) }
    }
    open var USPARTFROM: Int {
        get { return selectedUSTextbook.VALUE2!.toInt()! }
        set { selectedUSTextbook.VALUE2 = String(newValue) }
    }
    open var USUNITTO: Int {
        get { return selectedUSTextbook.VALUE3!.toInt()! }
        set { selectedUSTextbook.VALUE3 = String(newValue) }
    }
    open var USPARTTO: Int {
        get { return selectedUSTextbook.VALUE4!.toInt()! }
        set { selectedUSTextbook.VALUE4 = String(newValue) }
    }
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
    open var selectedDictIndex = 0 {
        didSet {
            setSelectedDictIndex()
        }
    }
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
            MUserSetting.getData(userid: self.userid) {
                self.arrUserSettings = $0
                self.selectedUSUserIndex = self.arrUserSettings.index { $0.KIND == 1 }!
                self.setSelectedLangIndex(self.arrLanguages.index { $0.ID! == self.USLANDID }!, complete: complete)
            }
        }
    }
    
    open func setSelectedLangIndex(_ langindex: Int, complete: (() -> Void)? = nil) {
        selectedLangIndex = langindex
        USLANDID = selectedLang.ID!
        selectedUSLangIndex = arrUserSettings.index { $0.KIND == 2 && $0.ENTITYID == self.USLANDID }!
        MDictionary.getDataByLang(self.USLANDID) {
            self.arrDictionaries = $0
            self.selectedDictIndex = self.arrDictionaries.index { $0.ID! == self.USDICTID }!
            MTextbook.getDataByLang(self.USLANDID) {
                self.arrTextbooks = $0
                self.selectedTextbookIndex = self.arrTextbooks.index { $0.ID! == self.USTEXTBOOKID }!
                complete?()
            }
        }
    }
    
    private func setSelectedTextbookIndex() {
        USTEXTBOOKID = selectedTextbook.ID!
        selectedUSTextbookIndex = arrUserSettings.index { $0.KIND == 3 && $0.ENTITYID == self.USTEXTBOOKID }!
        arrUnits = (1...selectedTextbook.UNITS!).map{ String($0) }
        arrParts = (selectedTextbook.PARTS?.components(separatedBy: " "))!
    }
    
    private func setSelectedDictIndex() {
        USDICTID = selectedDict.ID!
    }
    
    func updateLang(complete: (() -> Void)? = nil) {
        MUserSetting.update(selectedUSUser.ID!, langid: USLANDID) {
            print($0)
            complete?()
        }
    }
    
    func updateDict(complete: (() -> Void)? = nil) {
        MUserSetting.update(selectedUSLang.ID!, dictid: USDICTID) {
            print($0)
            complete?()
        }
    }
    
    func updateTextbook(complete: (() -> Void)? = nil) {
        MUserSetting.update(selectedUSLang.ID!, textbookid: USTEXTBOOKID) {
            print($0)
            complete?()
        }
    }
    
    func updateUnitFrom(complete: (() -> Void)? = nil) {
        MUserSetting.update(selectedUSTextbook.ID!, usunitfrom: USUNITFROM) {
            print($0)
            complete?()
        }
    }
    
    func updatePartFrom(complete: (() -> Void)? = nil) {
        MUserSetting.update(selectedUSTextbook.ID!, uspartfrom: USPARTFROM) {
            print($0)
            complete?()
        }
    }
    
    func updateUnitTo(complete: (() -> Void)? = nil) {
        MUserSetting.update(selectedUSTextbook.ID!, usunitto: USUNITTO) {
            print($0)
            complete?()
        }
    }
    
    func updatePartTo(complete: (() -> Void)? = nil) {
        MUserSetting.update(selectedUSTextbook.ID!, uspartto: USPARTTO) {
            print($0)
            complete?()
        }
    }
}
