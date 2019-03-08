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
    private var selectedUSUser0: MUserSetting!
    private var selectedUSUser1: MUserSetting!
    private var USLANGID: Int {
        get { return selectedUSUser0.VALUE1!.toInt()! }
        set { selectedUSUser0.VALUE1 = String(newValue) }
    }
    var USROWSPERPAGEOPTIONS: [Int] {
        get { return selectedUSUser0.VALUE2!.split(",").map { $0.toInt()! } }
    }
    var USROWSPERPAGE: Int {
        get { return selectedUSUser0.VALUE3!.toInt()! }
    }
    var USLEVELCOLORS: [Int: [Int]]!
    var USREADINTERVAL: Int {
        get { return selectedUSUser1.VALUE1!.toInt()! }
    }
    private var selectedUSLang: MUserSetting!
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
    private var selectedUSTextbook: MUserSetting!
    @objc
    var USUNITFROM: Int {
        get { return selectedUSTextbook.VALUE1!.toInt()! }
        set { selectedUSTextbook.VALUE1 = String(newValue) }
    }
    @objc
    var USPARTFROM: Int {
        get { return selectedUSTextbook.VALUE2!.toInt()! }
        set { selectedUSTextbook.VALUE2 = String(newValue) }
    }
    @objc
    var USUNITTO: Int {
        get { return selectedUSTextbook.VALUE3!.toInt()! }
        set { selectedUSTextbook.VALUE3 = String(newValue) }
    }
    @objc
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
    var selectedLang: MLanguage!
    var selectedLangIndex: Int {
        return arrLanguages.firstIndex { $0 == selectedLang }!
    }
    
    var arrDictsMean = [MDictMean]()
    @objc
    var arrDictItems = [MDictItem]()
    @objc
    var selectedDictItem: MDictItem! {
        didSet {
            USDICTITEM = selectedDictItem.DICTID
        }
    }
    var selectedDictItemIndex: Int {
        return arrDictItems.firstIndex { $0 == selectedDictItem }!
    }
    
    @objc
    var arrDictsNote = [MDictNote]()
    @objc
    var selectedDictNote: MDictNote = MDictNote() {
        didSet {
            USDICTNOTEID = selectedDictNote.ID
        }
    }
    var selectedDictNoteIndex: Int {
        return arrDictsNote.firstIndex { $0 == selectedDictNote } ?? 0
    }
    var hasNote: Bool { return !arrDictsNote.isEmpty }

    @objc
    var arrTextbooks = [MTextbook]()
    @objc
    var selectedTextbook: MTextbook! {
        didSet {
            USTEXTBOOKID = selectedTextbook.ID
            selectedUSTextbook = arrUserSettings.first { $0.KIND == 3 && $0.ENTITYID == selectedTextbook.ID }!
        }
    }
    var selectedTextbookIndex: Int {
        return arrTextbooks.firstIndex { $0 == selectedTextbook }!
    }
    
    @objc
    var arrUnits: [MSelectItem] {
        return selectedTextbook.arrUnits
    }
    var unitCount: Int {
        return arrUnits.count
    }
    @objc
    var arrParts: [MSelectItem] {
        return selectedTextbook.arrParts
    }
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
                self.selectedUSUser0 = self.arrUserSettings.first { $0.KIND == 1 && $0.ENTITYID == 0 }!
                self.selectedUSUser1 = self.arrUserSettings.first { $0.KIND == 1 && $0.ENTITYID == 1 }!
                let arr = self.selectedUSUser0.VALUE4!.split("\r\n").map { $0.split(",") }
                self.USLEVELCOLORS = [:]
                for v in arr {
                    self.USLEVELCOLORS[v[0].toInt()!] = [Int(v[1], radix: 16)!, Int(v[2], radix: 16)!]
                }
                return self.setSelectedLang(self.arrLanguages.first { $0.ID == self.USLANGID }!)
            }
    }
    
    func setSelectedLang(_ lang: MLanguage) -> Observable<()> {
        selectedLang = lang
        USLANGID = selectedLang.ID
        selectedUSLang = arrUserSettings.first { $0.KIND == 2 && $0.ENTITYID == self.USLANGID }!
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
                self.selectedDictItem = self.arrDictItems.first { $0.DICTID == self.USDICTITEM }!
                self.arrDictsNote = $0.1
                self.selectedDictNote = self.arrDictsNote.isEmpty ? MDictNote() : self.arrDictsNote.first { $0.ID == self.USDICTNOTEID }!
                self.arrTextbooks = $0.2
                self.selectedTextbook = self.arrTextbooks.first { $0.ID == self.USTEXTBOOKID }!
                self.arrAutoCorrect = $0.3
            }
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
        return MUserSetting.update(selectedUSUser0.ID, langid: USLANGID).map { print($0) }
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
