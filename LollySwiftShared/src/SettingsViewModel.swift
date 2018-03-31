//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation
import EZSwiftExtensions

class SettingsViewModel: NSObject {
    
    let userid = 1

    var arrUserSettings = [MUserSetting]()
    private var selectedUSUserIndex = 0
    private var selectedUSUser: MUserSetting {
        return arrUserSettings[selectedUSUserIndex]
    }
    var USLANDID: Int {
        get { return selectedUSUser.VALUE1!.toInt()! }
        set { selectedUSUser.VALUE1 = String(newValue) }
    }
    private var selectedUSLangIndex = 0
    private var selectedUSLang: MUserSetting {
        return arrUserSettings[selectedUSLangIndex]
    }
    var USTEXTBOOKID: Int {
        get { return selectedUSLang.VALUE1!.toInt()! }
        set { selectedUSLang.VALUE1 = String(newValue) }
    }
    var USDICTID: Int {
        get { return selectedUSLang.VALUE2!.toInt()! }
        set { selectedUSLang.VALUE2 = String(newValue) }
    }
    private var selectedUSTextbookIndex = 0
    private var selectedUSTextbook: MUserSetting {
        return arrUserSettings[selectedUSTextbookIndex]
    }
    var USUNITFROM: Int {
        get { return selectedUSTextbook.VALUE1!.toInt()! }
        set { selectedUSTextbook.VALUE1 = String(newValue) }
    }
    var USPARTFROM: Int {
        get { return selectedUSTextbook.VALUE2!.toInt()! }
        set { selectedUSTextbook.VALUE2 = String(newValue) }
    }
    var USUNITTO: Int {
        get { return selectedUSTextbook.VALUE3!.toInt()! }
        set { selectedUSTextbook.VALUE3 = String(newValue) }
    }
    var USPARTTO: Int {
        get { return selectedUSTextbook.VALUE4!.toInt()! }
        set { selectedUSTextbook.VALUE4 = String(newValue) }
    }
    var USUNITPARTFROM: Int {
        return USUNITFROM * 10 + USPARTFROM
    }
    var USUNITPARTTO: Int {
        return USUNITTO * 10 + USPARTTO
    }
    var isSingleUnitPart: Bool {
        return USUNITPARTFROM == USUNITPARTTO
    }
    var isInvalidUnitPart: Bool {
        return USUNITPARTFROM > USUNITPARTTO
    }

    @objc
    var arrLanguages = [MLanguage]()
    @objc
    private(set) var selectedLangIndex = 0
    var selectedLang: MLanguage {
        return arrLanguages[selectedLangIndex]
    }
    
    @objc
    var arrDictionaries = [MDictionary]()
    @objc
    var selectedDictIndex = 0 {
        didSet {
            setSelectedDictIndex()
        }
    }
    var selectedDict: MDictionary {
        return arrDictionaries[selectedDictIndex]
    }
    
    @objc
    var arrTextbooks = [MTextbook]()
    @objc
    var selectedTextbookIndex = 0 {
        didSet {
            setSelectedTextbookIndex()
        }
    }
    var selectedTextbook: MTextbook {
        return arrTextbooks[selectedTextbookIndex]
    }
    
    @objc
    var arrUnits = [String]()
    @objc
    var arrParts = [String]()
    
    override init() {
        super.init()
        getData {}
    }
    
    func getData(complete: @escaping () -> Void) {
        MLanguage.getData {
            self.arrLanguages = $0
            MUserSetting.getData(userid: self.userid) {
                self.arrUserSettings = $0
                self.selectedUSUserIndex = self.arrUserSettings.index { $0.KIND == 1 }!
                self.setSelectedLangIndex(self.arrLanguages.index { $0.ID == self.USLANDID }!, complete: complete)
            }
        }
    }
    
    func setSelectedLangIndex(_ langindex: Int, complete: @escaping () -> Void) {
        selectedLangIndex = langindex
        USLANDID = selectedLang.ID
        selectedUSLangIndex = arrUserSettings.index { $0.KIND == 2 && $0.ENTITYID == self.USLANDID }!
        MDictionary.getDataByLang(self.USLANDID) {
            self.arrDictionaries = $0
            self.selectedDictIndex = self.arrDictionaries.index { $0.ID == self.USDICTID }!
            MTextbook.getDataByLang(self.USLANDID) {
                self.arrTextbooks = $0
                self.selectedTextbookIndex = self.arrTextbooks.index { $0.ID == self.USTEXTBOOKID }!
                complete()
            }
        }
    }
    
    private func setSelectedTextbookIndex() {
        USTEXTBOOKID = selectedTextbook.ID
        selectedUSTextbookIndex = arrUserSettings.index { $0.KIND == 3 && $0.ENTITYID == self.USTEXTBOOKID }!
        arrUnits = (1...selectedTextbook.UNITS).map{ String($0) }
        arrParts = (selectedTextbook.PARTS.components(separatedBy: " "))
    }
    
    private func setSelectedDictIndex() {
        USDICTID = selectedDict.ID
    }
    
    func updateLang(complete: @escaping () -> Void) {
        MUserSetting.update(selectedUSUser.ID, langid: USLANDID) {
            print($0)
            complete()
        }
    }
    
    func updateDict(complete: @escaping () -> Void) {
        MUserSetting.update(selectedUSLang.ID, dictid: USDICTID) {
            print($0)
            complete()
        }
    }
    
    func updateTextbook(complete: @escaping () -> Void) {
        MUserSetting.update(selectedUSLang.ID, textbookid: USTEXTBOOKID) {
            print($0)
            complete()
        }
    }
    
    func updateUnitFrom(complete: @escaping () -> Void) {
        MUserSetting.update(selectedUSTextbook.ID, usunitfrom: USUNITFROM) {
            print($0)
            complete()
        }
    }
    
    func updatePartFrom(complete: @escaping () -> Void) {
        MUserSetting.update(selectedUSTextbook.ID, uspartfrom: USPARTFROM) {
            print($0)
            complete()
        }
    }
    
    func updateUnitTo(complete: @escaping () -> Void) {
        MUserSetting.update(selectedUSTextbook.ID, usunitto: USUNITTO) {
            print($0)
            complete()
        }
    }
    
    func updatePartTo(complete: @escaping () -> Void) {
        MUserSetting.update(selectedUSTextbook.ID, uspartto: USPARTTO) {
            print($0)
            complete()
        }
    }
}
