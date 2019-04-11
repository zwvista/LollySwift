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
    var USLEVELCOLORS: [Int: [String]]!
    var USREADINTERVAL: Int {
        get { return selectedUSUser1.VALUE1!.toInt()! }
    }
    private var selectedUSLang2: MUserSetting!
    var USTEXTBOOKID: Int {
        get { return selectedUSLang2.VALUE1!.toInt()! }
        set { selectedUSLang2.VALUE1 = String(newValue) }
    }
    var USDICTITEM: String {
        get { return selectedUSLang2.VALUE2! }
        set { selectedUSLang2.VALUE2 = newValue }
    }
    var USDICTNOTEID: Int {
        get { return selectedUSLang2.VALUE3?.toInt() ?? 0 }
        set { selectedUSLang2.VALUE3 = String(newValue) }
    }
    var USDICTITEMS: String {
        get { return selectedUSLang2.VALUE4 ?? "0" }
        set { selectedUSLang2.VALUE4 = newValue }
    }
    private var selectedUSLang3: MUserSetting!
    var USMACVOICEID: Int {
        get { return selectedUSLang3.VALUE2?.toInt() ?? 0 }
        set { selectedUSLang3.VALUE2 = String(newValue) }
    }
    var USIOSVOICEID: Int {
        get { return selectedUSLang3.VALUE3?.toInt() ?? 0 }
        set { selectedUSLang3.VALUE3 = String(newValue) }
    }
    private var selectedUSTextbook: MUserSetting!
    @objc
    var USUNITFROM: Int {
        get { return selectedUSTextbook.VALUE1!.toInt()! }
        set { selectedUSTextbook.VALUE1 = String(newValue) }
    }
    var USUNITFROMSTR: String {
        return selectedTextbook.UNITSTR(USUNITFROM)
    }
    @objc
    var USPARTFROM: Int {
        get { return selectedUSTextbook.VALUE2!.toInt()! }
        set { selectedUSTextbook.VALUE2 = String(newValue) }
    }
    var USPARTFROMSTR: String {
        return selectedTextbook.PARTSTR(USPARTFROM)
    }
    @objc
    var USUNITTO: Int {
        get { return selectedUSTextbook.VALUE3!.toInt()! }
        set { selectedUSTextbook.VALUE3 = String(newValue) }
    }
    var USUNITTOSTR: String {
        return selectedTextbook.UNITSTR(USUNITTO)
    }
    @objc
    var USPARTTO: Int {
        get { return selectedUSTextbook.VALUE4!.toInt()! }
        set { selectedUSTextbook.VALUE4 = String(newValue) }
    }
    var USPARTTOSTR: String {
        return selectedTextbook.PARTSTR(USPARTTO)
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
    var selectedLang: MLanguage!
    var selectedLangIndex: Int {
        return arrLanguages.firstIndex { $0 == selectedLang } ?? 0
    }

    @objc
    var arrMacVoices: [MVoice]!
    @objc
    var arriOSVoices: [MVoice]!
    @objc
    var selectedMacVoice = MVoice() {
        didSet {
            USMACVOICEID = selectedMacVoice.ID
        }
    }
    var macVoiceName: String {
        return selectedMacVoice.VOICENAME
    }
    var selectediOSVoice = MVoice()
    var selectediOSVoiceIndex: Int {
        return arriOSVoices.firstIndex { $0 == selectediOSVoice } ?? 0
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
        return arrDictItems.firstIndex { $0 == selectedDictItem } ?? 0
    }
    
    @objc
    var arrDictsNote = [MDictNote]()
    @objc
    var selectedDictNote = MDictNote() {
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
            selectedUSTextbook = arrUserSettings.first { $0.KIND == 11 && $0.ENTITYID == selectedTextbook.ID }!
            toType = isSingleUnit ? 0 : isSingleUnitPart ? 1 : 2
        }
    }
    var selectedTextbookIndex: Int {
        return arrTextbooks.firstIndex { $0 == selectedTextbook } ?? 0
    }
    @objc
    var arrTextbookFilters = [MSelectItem]()
    
    @objc
    var arrUnits: [MSelectItem] {
        return selectedTextbook.arrUnits
    }
    var unitCount: Int {
        return arrUnits.count
    }
    @objc
    var unitsInAll: String {
        return "(\(unitCount) in all)"
    }
    @objc
    var arrParts: [MSelectItem] {
        return selectedTextbook.arrParts
    }
    var partCount: Int {
        return arrParts.count
    }
    var isSingleUnit: Bool {
        return USUNITFROM == USUNITTO && USPARTFROM == 1 && USPARTTO == partCount
    }
    var isSinglePart: Bool {
        return partCount == 1
    }
    
    let arrToTypes = ["Unit", "Part", "To"]
    @objc
    var toType = 0

    var arrAutoCorrect = [MAutoCorrect]()
    
    weak var delegate: SettingsViewModelDelegate?
    
    func getData() -> Observable<()> {
        return Observable.zip(MLanguage.getData(), MUserSetting.getData(userid: CommonApi.userid))
            .flatMap { result -> Observable<()> in
                self.arrLanguages = result.0
                self.arrUserSettings = result.1
                self.selectedUSUser0 = self.arrUserSettings.first { $0.KIND == 1 && $0.ENTITYID == 0 }!
                self.selectedUSUser1 = self.arrUserSettings.first { $0.KIND == 1 && $0.ENTITYID == 1 }!
                let arr = self.selectedUSUser0.VALUE4!.split("\r\n").map { $0.split(",") }
                // https://stackoverflow.com/questions/39791084/swift-3-array-to-dictionary
                self.USLEVELCOLORS = Dictionary(uniqueKeysWithValues: arr.map { ($0[0].toInt()!, [$0[1], $0[2]]) })
                self.delegate?.onGetData()
                return self.setSelectedLang(self.arrLanguages.first { $0.ID == self.USLANGID }!)
            }
    }

    func setSelectedLang(_ lang: MLanguage) -> Observable<()> {
        let isinit = USLANGID == lang.ID
        selectedLang = lang
        USLANGID = selectedLang.ID
        selectedUSLang2 = arrUserSettings.first { $0.KIND == 2 && $0.ENTITYID == self.USLANGID }!
        selectedUSLang3 = arrUserSettings.first { $0.KIND == 3 && $0.ENTITYID == self.USLANGID }!
        let arrDicts = USDICTITEMS.split("\r\n")
        return Observable.zip(MDictMean.getDataByLang(USLANGID),
                              MDictNote.getDataByLang(USLANGID),
                              MTextbook.getDataByLang(USLANGID),
                              MAutoCorrect.getDataByLang(USLANGID),
                              MVoice.getDataByLang(USLANGID))
            .flatMap { result -> Observable<()> in
                self.arrDictsMean = result.0
                var i = 0
                self.arrDictItems = arrDicts.flatMap { d -> [MDictItem] in
                    if d == "0" {
                        return self.arrDictsMean.map { MDictItem(id: String($0.DICTID), name: $0.DICTNAME) }
                    } else {
                        i += 1
                        return [MDictItem(id: d, name: "Custom\(i)")]
                    }
                }
                self.selectedDictItem = self.arrDictItems.first { $0.DICTID == self.USDICTITEM }!
                self.arrDictsNote = result.1
                if self.arrDictsNote.isEmpty { self.arrDictsNote.append(MDictNote()) }
                self.selectedDictNote = self.arrDictsNote.first { $0.DICTID == self.USDICTNOTEID } ?? self.arrDictsNote[0]
                self.arrTextbooks = result.2
                self.selectedTextbook = self.arrTextbooks.first { $0.ID == self.USTEXTBOOKID }!
                self.arrTextbookFilters = self.arrTextbooks.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) }
                self.arrTextbookFilters.insert(MSelectItem(value: 0, label: "All Textbooks"), at: 0)
                self.arrAutoCorrect = result.3
                let arrVoices = result.4
                self.arrMacVoices = arrVoices.filter { $0.VOICETYPEID == 2 }
                if self.arrMacVoices.isEmpty { self.arrMacVoices.append(MVoice()) }
                self.arriOSVoices = arrVoices.filter { $0.VOICETYPEID == 3 }
                if self.arriOSVoices.isEmpty { self.arriOSVoices.append(MVoice()) }
                self.selectedMacVoice = self.arrMacVoices.first { $0.ID == self.USMACVOICEID } ?? self.arrMacVoices[0]
                self.selectediOSVoice = self.arriOSVoices.first { $0.ID == self.USIOSVOICEID } ?? self.arriOSVoices[0]
                if isinit {
                    self.delegate?.onUpdateLang()
                    return Observable.just(())
                } else {
                    return self.updateLang()
                }
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
        return MUserSetting.update(selectedUSUser0.ID, langid: USLANGID).map { print($0); self.delegate?.onUpdateLang() }
    }
    
    func updateDictItem() -> Observable<()> {
        return MUserSetting.update(selectedUSLang2.ID, dictitem: USDICTITEM).map { print($0); self.delegate?.onUpdateDictItem() }
    }
    
    func updateDictNote() -> Observable<()> {
        return MUserSetting.update(selectedUSLang2.ID, dictnoteid: USDICTNOTEID).map { print($0); self.delegate?.onUpdateDictNote() }
    }

    func updateTextbook() -> Observable<()> {
        return MUserSetting.update(selectedUSLang2.ID, textbookid: USTEXTBOOKID).map { print($0); self.delegate?.onUpdateTextbook() }
    }
    
    func updateMacVoice() -> Observable<()> {
        return MUserSetting.update(selectedUSLang3.ID, macvoiceid: USMACVOICEID).map { print($0); self.delegate?.onUpdateMacVoice() }
    }
    
    func updateiOSVoice() -> Observable<()> {
        return MUserSetting.update(selectedUSLang3.ID, iosvoiceid: USIOSVOICEID).map { print($0); self.delegate?.onUpdateiOSVoice() }
    }

    func autoCorrectInput(text: String) -> String {
        return MAutoCorrect.autoCorrect(text: text, arrAutoCorrect: arrAutoCorrect, colFunc1: { $0.INPUT }, colFunc2: { $0.EXTENDED })
    }
    
    func updateUnitFrom() -> Observable<()> {
        return doUpdateUnitFrom(v: USUNITFROM, check: false).flatMap {
            return self.toType == 0 ? self.doUpdateSingleUnit() :
                self.toType == 1 || self.isInvalidUnitPart ? self.doUpdateUnitPartTo() :
                Observable.empty()
        }
    }
    
    func updatePartFrom() -> Observable<()> {
        return doUpdatePartFrom(v: USPARTFROM, check: false).flatMap {
            return self.toType == 1 || self.isInvalidUnitPart ? self.doUpdateUnitPartTo() : Observable.empty()
        }
    }
    
    func updateUnitTo() -> Observable<()> {
        return doUpdateUnitTo(v: USUNITTO, check: false).flatMap {
            return self.isInvalidUnitPart ? self.doUpdateUnitPartFrom() : Observable.empty()
        }
    }
    
    func updatePartTo() -> Observable<()> {
        return doUpdatePartTo(v: USPARTTO, check: false).flatMap {
            return self.isInvalidUnitPart ? self.doUpdateUnitPartFrom() : Observable.empty()
        }
    }
    
    func updateToType() -> Observable<()> {
        return toType == 0 ? doUpdateSingleUnit() :
            toType == 1 ? doUpdateUnitPartTo() : Observable.empty()
    }

    func previousUnitPart() -> Observable<()> {
        if toType == 0 {
            if USUNITFROM > 1 {
                return Observable.zip(doUpdateUnitFrom(v: USUNITFROM - 1), doUpdateUnitTo(v: USUNITFROM)).map{_ in }
            } else {
                return Observable.empty()
            }
        } else if USPARTFROM > 1 {
            return Observable.zip(doUpdatePartFrom(v: USPARTFROM - 1), doUpdateUnitPartTo()).map{_ in }
        } else if USUNITFROM > 1 {
            return Observable.zip(doUpdateUnitFrom(v: USUNITFROM - 1), doUpdatePartFrom(v: partCount), doUpdateUnitPartTo()).map{_ in }
        } else {
            return Observable.empty()
        }
    }
    
    func nextUnitPart() -> Observable<()> {
        if toType == 0 {
            if USUNITFROM < unitCount {
                return Observable.zip(doUpdateUnitFrom(v: USUNITFROM + 1), doUpdateUnitTo(v: USUNITFROM)).map{_ in }
            } else {
                return Observable.empty()
            }
        } else if USPARTFROM < partCount {
            return Observable.zip(doUpdatePartFrom(v: USPARTFROM + 1), doUpdateUnitPartTo()).map{_ in }
        } else if USUNITFROM < unitCount {
            return Observable.zip(doUpdateUnitFrom(v: USUNITFROM + 1), doUpdatePartFrom(v: 1), doUpdateUnitPartTo()).map{_ in }
        } else {
            return Observable.empty()
        }
    }
    
    private func doUpdateUnitPartFrom() -> Observable<()> {
        return Observable.zip(doUpdateUnitFrom(v: USUNITTO), doUpdatePartFrom(v: USPARTTO)).map{_ in }
    }
    
    private func doUpdateUnitPartTo() -> Observable<()> {
        return Observable.zip(doUpdateUnitTo(v: USUNITFROM), doUpdatePartTo(v: USPARTFROM)).map{_ in }
    }
    
    private func doUpdateSingleUnit() -> Observable<()> {
        return Observable.zip(doUpdateUnitTo(v: USUNITFROM), doUpdatePartFrom(v: 1), doUpdatePartTo(v: partCount)).map{_ in }
    }

    private func doUpdateUnitFrom(v: Int, check: Bool = true) -> Observable<()> {
        guard !check || USUNITFROM != v else { return Observable.empty() }
        USUNITFROM = v
        return MUserSetting.update(selectedUSTextbook.ID, usunitfrom: USUNITFROM).map { print($0); self.delegate?.onUpdateUnitFrom() }
    }
    
    private func doUpdatePartFrom(v: Int, check: Bool = true) -> Observable<()> {
        guard !check || USPARTFROM != v else { return Observable.empty() }
        USPARTFROM = v
        return MUserSetting.update(selectedUSTextbook.ID, uspartfrom: USPARTFROM).map { print($0); self.delegate?.onUpdatePartFrom()  }
    }
    
    private func doUpdateUnitTo(v: Int, check: Bool = true) -> Observable<()> {
        guard !check || USUNITTO != v else { return Observable.empty() }
        USUNITTO = v
        return MUserSetting.update(selectedUSTextbook.ID, usunitto: USUNITTO).map { print($0); self.delegate?.onUpdateUnitTo() }
    }
    
    private func doUpdatePartTo(v: Int, check: Bool = true) -> Observable<()> {
        guard !check || USPARTTO != v else { return Observable.empty() }
        USPARTTO = v
        return MUserSetting.update(selectedUSTextbook.ID, uspartto: USPARTTO).map { print($0); self.delegate?.onUpdatePartTo() }
    }
    
}

protocol SettingsViewModelDelegate : NSObjectProtocol {
    func onGetData()
    func onUpdateLang()
    func onUpdateDictItem()
    func onUpdateDictNote()
    func onUpdateTextbook()
    func onUpdateUnitFrom()
    func onUpdatePartFrom()
    func onUpdateUnitTo()
    func onUpdatePartTo()
    func onUpdateMacVoice()
    func onUpdateiOSVoice()
}
extension SettingsViewModelDelegate {
    func onGetData(){}
    func onUpdateLang(){}
    func onUpdateDictItem(){}
    func onUpdateDictNote(){}
    func onUpdateTextbook(){}
    func onUpdateUnitFrom(){}
    func onUpdatePartFrom(){}
    func onUpdateUnitTo(){}
    func onUpdatePartTo(){}
    func onUpdateMacVoice(){}
    func onUpdateiOSVoice(){}
}
