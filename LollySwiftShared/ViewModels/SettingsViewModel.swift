//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation
import EZSwiftExtensions
import RxSwift

class SettingsViewModel: NSObject {
    
    let userid = 1

    var arrUserSettings = [MUserSetting]()
    private var selectedUSUserIndex = 0
    private var selectedUSUser: MUserSetting {
        return arrUserSettings[selectedUSUserIndex]
    }
    private var USLANGID: Int {
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
    var USDICTITEM: String {
        get { return selectedUSLang.VALUE2! }
        set { selectedUSLang.VALUE2 = newValue }
    }
    var USDICTNOTEID: Int {
        get { return selectedUSLang.VALUE3!.toInt()! }
        set { selectedUSLang.VALUE3 = String(newValue) }
    }
    var USDICTITEMS: String {
        get { return selectedUSLang.VALUE4 ?? "0" }
        set { selectedUSLang.VALUE4 = newValue }
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
    var isSingleUnit: Bool {
        return USUNITFROM == USUNITTO && USPARTFROM == 1 && USPARTTO == partCount
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
    
    var arrDictsMean = [MDictMean]()
    @objc
    var arrDictItems = [MDictItem]()
    @objc
    var selectedDictItemIndex = 0 {
        didSet {
            USDICTITEM = selectedDictItem.DICTID
        }
    }
    var selectedDictItem: MDictItem {
        return arrDictItems[selectedDictItemIndex]
    }
    
    @objc
    var arrDictsNote = [MDictNote]()
    @objc
    var selectedDictNoteIndex = 0 {
        didSet {
            USDICTNOTEID = selectedDictNote?.ID ?? 0
        }
    }
    var selectedDictNote: MDictNote? {
        return arrDictsNote.isEmpty ? nil : arrDictsNote[selectedDictNoteIndex]
    }
    var hasNote: Bool { return !arrDictsNote.isEmpty }

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
    var unitCount: Int {
        return arrUnits.count
    }
    @objc
    var arrParts = [String]()
    var partCount: Int {
        return arrParts.count
    }
    var isSinglePart: Bool {
        return partCount == 1
    }
    
    var arrAutoCorrect = [MAutoCorrect]()
    
    func getData() -> Observable<()> {
        return Observable.zip(MLanguage.getData(), MUserSetting.getData(userid: self.userid))
            .flatMap { result -> Observable<()> in
                self.arrLanguages = result.0
                self.arrUserSettings = result.1
                self.selectedUSUserIndex = self.arrUserSettings.index { $0.KIND == 1 }!
                return self.setSelectedLangIndex(self.arrLanguages.index { $0.ID == self.USLANGID }!)
            }
    }
    
    func setSelectedLangIndex(_ langindex: Int) -> Observable<()> {
        selectedLangIndex = langindex
        USLANGID = selectedLang.ID
        selectedUSLangIndex = arrUserSettings.index { $0.KIND == 2 && $0.ENTITYID == self.USLANGID }!
        let arrDicts = USDICTITEMS.split("\r\n")
        return Observable.zip(MDictMean.getDataByLang(self.USLANGID),
                              MDictNote.getDataByLang(self.USLANGID),
                              MTextbook.getDataByLang(self.USLANGID),
                              MAutoCorrect.getDataByLang(self.USLANGID))
            .map {
                self.arrDictsMean = $0.0
                var i = 0
                self.arrDictItems = arrDicts.flatMap { d -> [MDictItem] in
                    if d == "0" {
                        return self.arrDictsMean.map { MDictItem(id: String($0.DICTID), name: $0.DICTNAME!) }
                    } else {
                        i += 1
                        return [MDictItem(id: d, name: "Custom\(i)")]
                    }
                }
                self.selectedDictItemIndex = self.arrDictItems.index { $0.DICTID == self.USDICTITEM } ?? 0
                self.arrDictsNote = $0.1
                if !self.arrDictsNote.isEmpty {
                    self.selectedDictNoteIndex = self.arrDictsNote.index { $0.ID == self.USDICTNOTEID }!
                }
                self.arrTextbooks = $0.2
                self.selectedTextbookIndex = self.arrTextbooks.index { $0.ID == self.USTEXTBOOKID }!
                self.arrAutoCorrect = $0.3
            }
    }
    
    private func setSelectedTextbookIndex() {
        USTEXTBOOKID = selectedTextbook.ID
        selectedUSTextbookIndex = arrUserSettings.index { $0.KIND == 3 && $0.ENTITYID == self.USTEXTBOOKID }!
        arrUnits = CommonApi.unitsFrom(info: selectedTextbook.UNITINFO)
        arrParts = CommonApi.partsFrom(parts: selectedTextbook.PARTS)
    }
    
    func dictHtml(word: String, dictids: [String]) -> String {
        var s = "<html><body>\n"
        for (i, dictid) in dictids.enumerated() {
            let item = arrDictsMean.first { String($0.DICTID) == dictid }!
            let ifrId = "ifr\(i + 1)"
            let url = item.urlString(word: word, arrAutoCorrect: arrAutoCorrect)
            s += "<iframe id='\(ifrId)' frameborder='1' style='width:100%; height:500px; display:block' src='\(url)'></iframe>\n"
        }
        s += "</body></html>\n"
        return s
    }
    
    func updateLang() -> Observable<()> {
        return MUserSetting.update(selectedUSUser.ID, langid: USLANGID).map { print($0) }
    }
    
    func updateDictItem() -> Observable<()> {
        return MUserSetting.update(selectedUSLang.ID, dictitem: USDICTITEM).map { print($0) }
    }
    
    func updateDictNote() -> Observable<()> {
        return MUserSetting.update(selectedUSLang.ID, dictnoteid: USDICTNOTEID).map { print($0) }
    }

    func updateTextbook() -> Observable<()> {
        return MUserSetting.update(selectedUSLang.ID, textbookid: USTEXTBOOKID).map { print($0) }
    }
    
    func updateUnitFrom() -> Observable<()> {
        return MUserSetting.update(selectedUSTextbook.ID, usunitfrom: USUNITFROM).map { print($0) }
    }
    
    func updatePartFrom() -> Observable<()> {
        return MUserSetting.update(selectedUSTextbook.ID, uspartfrom: USPARTFROM).map { print($0) }
    }
    
    func updateUnitTo() -> Observable<()> {
        return MUserSetting.update(selectedUSTextbook.ID, usunitto: USUNITTO).map { print($0) }
    }
    
    func updatePartTo() -> Observable<()> {
        return MUserSetting.update(selectedUSTextbook.ID, uspartto: USPARTTO).map { print($0) }
    }
    
    func autoCorrectInput(text: String) -> String {
        return MAutoCorrect.autoCorrect(text: text, arrAutoCorrect: arrAutoCorrect, colFunc1: { $0.INPUT }, colFunc2: { $0.EXTENDED })
    }
}
