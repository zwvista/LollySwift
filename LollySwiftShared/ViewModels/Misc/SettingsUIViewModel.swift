//
//  SettingsUIViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2020/12/25.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation
import EZSwiftExtensions
import RxSwift

class SettingsViewModel: NSObject, ObservableObject {
    
    var arrUSMappings = [MUSMapping]()
    var arrUserSettings = [MUserSetting]()
    private func getUSValue(info: MUserSettingInfo) -> String? {
        arrUserSettings.first { $0.ID == info.USERSETTINGID }!.value(forKeyPath: "VALUE\(info.VALUEID)") as? String
    }
    private func setUSValue(info: MUserSettingInfo, value: String) {
        arrUserSettings.first { $0.ID == info.USERSETTINGID }!.setValue(value, forKey: "VALUE\(info.VALUEID)")
    }
    private var INFO_USLANG = MUserSettingInfo()
    private var USLANG: Int {
        get { getUSValue(info: INFO_USLANG)!.toInt()! }
        set { setUSValue(info: INFO_USLANG, value: String(newValue)) }
    }
    private var INFO_USROWSPERPAGEOPTIONS = MUserSettingInfo()
    var USROWSPERPAGEOPTIONS: [Int] {
        get { getUSValue(info: INFO_USROWSPERPAGEOPTIONS)!.split(",").map { $0.toInt()! } }
    }
    private var INFO_USROWSPERPAGE = MUserSettingInfo()
    var USROWSPERPAGE: Int {
        get { getUSValue(info: INFO_USROWSPERPAGE)!.toInt()! }
    }
    private var INFO_USLEVELCOLORS = MUserSettingInfo()
    var USLEVELCOLORS: [Int: [String]]!
    private var INFO_USSCANINTERVAL = MUserSettingInfo()
    var USSCANINTERVAL: Int {
        get { getUSValue(info: INFO_USSCANINTERVAL)!.toInt()! }
        set { setUSValue(info: INFO_USSCANINTERVAL, value: String(newValue)) }
    }
    private var INFO_USREVIEWINTERVAL = MUserSettingInfo()
    var USREVIEWINTERVAL: Int {
        get { getUSValue(info: INFO_USREVIEWINTERVAL)!.toInt()! }
        set { setUSValue(info: INFO_USREVIEWINTERVAL, value: String(newValue)) }
    }
    private var INFO_USTEXTBOOK = MUserSettingInfo()
    var USTEXTBOOK: Int {
        get { getUSValue(info: INFO_USTEXTBOOK)!.toInt()! }
        set { setUSValue(info: INFO_USTEXTBOOK, value: String(newValue)) }
    }
    private var INFO_USDICTREFERENCE = MUserSettingInfo()
    var USDICTREFERENCE: String {
        get { getUSValue(info: INFO_USDICTREFERENCE)! }
        set { setUSValue(info: INFO_USDICTREFERENCE, value: newValue) }
    }
    private var INFO_USDICTNOTE = MUserSettingInfo()
    var USDICTNOTE: Int {
        get { getUSValue(info: INFO_USDICTNOTE)?.toInt() ?? 0 }
        set { setUSValue(info: INFO_USDICTNOTE, value: String(newValue) )}
    }
    private var INFO_USDICTSREFERENCE = MUserSettingInfo()
    var USDICTSREFERENCE: String {
        get { getUSValue(info: INFO_USDICTSREFERENCE) ?? "" }
        set { setUSValue(info: INFO_USDICTSREFERENCE, value: newValue) }
    }
    private var INFO_USDICTTRANSLATION = MUserSettingInfo()
    var USDICTTRANSLATION: Int {
        get { getUSValue(info: INFO_USDICTTRANSLATION)?.toInt() ?? 0 }
        set { setUSValue(info: INFO_USDICTTRANSLATION, value: String(newValue)) }
    }
    private var INFO_USMACVOICE = MUserSettingInfo()
    var USMACVOICE: Int {
        get { getUSValue(info: INFO_USMACVOICE)?.toInt() ?? 0 }
        set { setUSValue(info: INFO_USMACVOICE, value: String(newValue)) }
    }
    private var INFO_USIOSVOICE = MUserSettingInfo()
    var USIOSVOICE: Int {
        get { getUSValue(info: INFO_USIOSVOICE)?.toInt() ?? 0 }
        set { setUSValue(info: INFO_USIOSVOICE, value: String(newValue)) }
    }
    private var INFO_USUNITFROM = MUserSettingInfo()
    var USUNITFROM: Int {
        get { getUSValue(info: INFO_USUNITFROM)!.toInt()! }
        set { setUSValue(info: INFO_USUNITFROM, value: String(newValue)) }
    }
    var USUNITFROMSTR: String { selectedTextbook.UNITSTR(USUNITFROM) }
    private var INFO_USPARTFROM = MUserSettingInfo()
    var USPARTFROM: Int {
        get { getUSValue(info: INFO_USPARTFROM)!.toInt()! }
        set { setUSValue(info: INFO_USPARTFROM, value: String(newValue)) }
    }
    var USPARTFROMSTR: String { selectedTextbook.PARTSTR(USPARTFROM) }
    private var INFO_USUNITTO = MUserSettingInfo()
    var USUNITTO: Int {
        get { getUSValue(info: INFO_USUNITTO)!.toInt()! }
        set { setUSValue(info: INFO_USUNITTO, value: String(newValue)) }
    }
    var USUNITTOSTR: String { selectedTextbook.UNITSTR(USUNITTO) }
    private var INFO_USPARTTO = MUserSettingInfo()
    var USPARTTO: Int {
        get { getUSValue(info: INFO_USPARTTO)!.toInt()! }
        set { setUSValue(info: INFO_USPARTTO, value: String(newValue)) }
    }
    var USPARTTOSTR: String { selectedTextbook.PARTSTR(USPARTTO) }
    var USUNITPARTFROM: Int { USUNITFROM * 10 + USPARTFROM }
    var USUNITPARTTO: Int { USUNITTO * 10 + USPARTTO }
    var isSingleUnitPart: Bool { USUNITPARTFROM == USUNITPARTTO }
    var isInvalidUnitPart: Bool { USUNITPARTFROM > USUNITPARTTO }

    @Published
    var arrLanguages = [MLanguage]()
    @Published
    var selectedLang = MLanguage()
    var selectedLangIndex: Int { arrLanguages.firstIndex { $0 == selectedLang } ?? 0 }

    var arrMacVoices: [MVoice]!
    var arriOSVoices: [MVoice]!
    var selectedMacVoice = MVoice() {
        didSet {
            USMACVOICE = selectedMacVoice.ID
        }
    }
    var macVoiceName: String { selectedMacVoice.VOICENAME }
    var selectediOSVoice = MVoice()
    var selectediOSVoiceIndex: Int { arriOSVoices.firstIndex { $0 == selectediOSVoice } ?? 0 }

    @Published
    var arrDictsReference = [MDictionary]()
    @Published
    var selectedDictReference = MDictionary() {
        didSet {
            USDICTREFERENCE = String(selectedDictReference.DICTID)
        }
    }
    var selectedDictsReference = [MDictionary]() {
        didSet {
            USDICTSREFERENCE = selectedDictsReference.map { String($0.DICTID) }.joined(separator: ",")
        }
    }
    var selectedDictReferenceIndex: Int { arrDictsReference.firstIndex { $0 == selectedDictReference } ?? 0 }
    
    var arrDictsNote = [MDictionary]()
    var selectedDictNote = MDictionary() {
        didSet {
            USDICTNOTE = selectedDictNote.DICTID
        }
    }
    var selectedDictNoteIndex: Int { arrDictsNote.firstIndex { $0 == selectedDictNote } ?? 0 }
    var hasDictNote: Bool { arrDictsNote[0].ID != 0 }
    
    var arrDictsTranslation = [MDictionary]()
    var selectedDictTranslation = MDictionary() {
        didSet {
            USDICTTRANSLATION = selectedDictTranslation.DICTID
        }
    }
    var selectedDictTranslationIndex: Int { arrDictsTranslation.firstIndex { $0 == selectedDictTranslation } ?? 0 }
    var hasDictTranslation: Bool { !arrDictsTranslation.isEmpty }

    var arrTextbooks = [MTextbook]()
    var selectedTextbook: MTextbook! {
        didSet {
            USTEXTBOOK = selectedTextbook.ID
            INFO_USUNITFROM = getUSInfo(name: MUSMapping.NAME_USUNITFROM)
            INFO_USPARTFROM = getUSInfo(name: MUSMapping.NAME_USPARTFROM)
            INFO_USUNITTO = getUSInfo(name: MUSMapping.NAME_USUNITTO)
            INFO_USPARTTO = getUSInfo(name: MUSMapping.NAME_USPARTTO)
            toType = isSingleUnit ? .unit : isSingleUnitPart ? .part : .to
        }
    }
    var selectedTextbookIndex: Int { arrTextbooks.firstIndex { $0 == selectedTextbook } ?? 0 }
    var arrTextbookFilters = [MSelectItem]()
    var arrWebTextbookFilters = [MSelectItem]()

    var arrUnits: [MSelectItem] { selectedTextbook.arrUnits }
    var unitCount: Int { arrUnits.count }
    var unitsInAll: String { "(\(unitCount) in all)" }
    var arrParts: [MSelectItem] { selectedTextbook.arrParts }
    var partCount: Int { arrParts.count }
    var isSingleUnit: Bool { USUNITFROM == USUNITTO && USPARTFROM == 1 && USPARTTO == partCount }
    var isSinglePart: Bool { partCount == 1 }
    var LANGINFO: String { "\(selectedLang.LANGNAME)" }
    var TEXTBOOKINFO: String { "\(LANGINFO)/\(selectedTextbook.TEXTBOOKNAME)" }
    var UNITINFO: String { "\(TEXTBOOKINFO)/\(USUNITFROMSTR) \(USPARTFROMSTR) ~ \(USUNITTOSTR) \(USPARTTOSTR)" }
    
    let arrToTypes = ["Unit", "Part", "To"]
    var toType: UnitPartToType = .unit
    
    static let arrScopeWordFilters = ["Word", "Note"]
    static let arrScopePhraseFilters = ["Phrase", "Translation"]
    static let arrScopePatternFilters = ["Pattern", "Note", "Tags"]

    var arrAutoCorrect = [MAutoCorrect]()
    var arrDictTypes = [MCode]()
    
    weak var delegate: SettingsViewModelDelegate?
    
    override init() {
        super.init()
    }
    
    init(_ x: SettingsViewModel) {
        arrUSMappings = x.arrUSMappings
        arrUserSettings = x.arrUserSettings
        INFO_USLANG = x.INFO_USLANG
        INFO_USROWSPERPAGEOPTIONS = x.INFO_USROWSPERPAGEOPTIONS
        INFO_USROWSPERPAGE = x.INFO_USROWSPERPAGE
        INFO_USLEVELCOLORS = x.INFO_USLEVELCOLORS
        USLEVELCOLORS = x.USLEVELCOLORS
        INFO_USSCANINTERVAL = x.INFO_USSCANINTERVAL
        INFO_USREVIEWINTERVAL = x.INFO_USREVIEWINTERVAL
        INFO_USTEXTBOOK = x.INFO_USTEXTBOOK
        INFO_USDICTREFERENCE = x.INFO_USDICTREFERENCE
        INFO_USDICTNOTE = x.INFO_USDICTNOTE
        INFO_USDICTSREFERENCE = x.INFO_USDICTSREFERENCE
        INFO_USDICTTRANSLATION = x.INFO_USDICTTRANSLATION
        INFO_USMACVOICE = x.INFO_USMACVOICE
        INFO_USIOSVOICE = x.INFO_USIOSVOICE
        INFO_USUNITFROM = x.INFO_USUNITFROM
        INFO_USPARTFROM = x.INFO_USPARTFROM
        INFO_USUNITTO = x.INFO_USUNITTO
        INFO_USPARTTO = x.INFO_USPARTTO
        arrLanguages = x.arrLanguages
        selectedLang = x.selectedLang
        arrMacVoices = x.arrMacVoices
        selectedMacVoice = x.selectedMacVoice
        arriOSVoices = x.arriOSVoices
        selectediOSVoice = x.selectediOSVoice
        arrDictsReference = x.arrDictsReference
        selectedDictReference = x.selectedDictReference
        selectedDictsReference = x.selectedDictsReference
        arrDictsNote = x.arrDictsNote
        selectedDictNote = x.selectedDictNote
        arrDictsTranslation = x.arrDictsTranslation
        selectedDictTranslation = x.selectedDictTranslation
        arrTextbooks = x.arrTextbooks
        selectedTextbook = x.selectedTextbook
        arrTextbookFilters = x.arrTextbookFilters
        arrWebTextbookFilters = x.arrWebTextbookFilters
        toType = x.toType
        arrAutoCorrect = x.arrAutoCorrect
        arrDictTypes = x.arrDictTypes
        delegate = x.delegate
        super.init()
    }
    
    private func getUSInfo(name: String) -> MUserSettingInfo {
        let o = arrUSMappings.first { $0.NAME == name }!
        let entityid = o.ENTITYID != -1 ? o.ENTITYID :
            o.LEVEL == 1 ? selectedLang.ID :
            o.LEVEL == 2 ? selectedTextbook.ID :
            0
        let o2 = arrUserSettings.first { $0.KIND == o.KIND && $0.ENTITYID == entityid }!
        return MUserSettingInfo(USERSETTINGID: o2.ID, VALUEID: o.VALUEID)
    }
    
    func getData() -> Observable<()> {
        Observable.zip(MLanguage.getData(),
                              MUSMapping.getData(),
                              MUserSetting.getData(userid: CommonApi.userid),
                              MCode.getData())
            .flatMap { result -> Observable<()> in
                self.arrLanguages = result.0
                self.arrUSMappings = result.1
                self.arrUserSettings = result.2
                self.arrDictTypes = result.3
                self.INFO_USLANG = self.getUSInfo(name: MUSMapping.NAME_USLANG)
                self.INFO_USROWSPERPAGEOPTIONS = self.getUSInfo(name: MUSMapping.NAME_USROWSPERPAGEOPTIONS)
                self.INFO_USROWSPERPAGE = self.getUSInfo(name: MUSMapping.NAME_USROWSPERPAGE)
                self.INFO_USLEVELCOLORS = self.getUSInfo(name: MUSMapping.NAME_USLEVELCOLORS)
                self.INFO_USSCANINTERVAL = self.getUSInfo(name: MUSMapping.NAME_USSCANINTERVAL)
                self.INFO_USREVIEWINTERVAL = self.getUSInfo(name: MUSMapping.NAME_USREVIEWINTERVAL)
                let arr = self.getUSValue(info: self.INFO_USLEVELCOLORS)!.split("\r\n").map { $0.split(",") }
                // https://stackoverflow.com/questions/39791084/swift-3-array-to-dictionary
                self.USLEVELCOLORS = Dictionary(uniqueKeysWithValues: arr.map { ($0[0].toInt()!, [$0[1], $0[2]]) })
                self.delegate?.onGetData()
                return self.setSelectedLang(self.arrLanguages.first { $0.ID == self.USLANG }!)
            }
    }

    func setSelectedLang(_ lang: MLanguage) -> Observable<()> {
        let isinit = USLANG == lang.ID
        USLANG = lang.ID
        selectedLang = lang
        INFO_USTEXTBOOK = getUSInfo(name: MUSMapping.NAME_USTEXTBOOK)
        INFO_USDICTREFERENCE = getUSInfo(name: MUSMapping.NAME_USDICTREFERENCE)
        INFO_USDICTNOTE = getUSInfo(name: MUSMapping.NAME_USDICTNOTE)
        INFO_USDICTSREFERENCE = getUSInfo(name: MUSMapping.NAME_USDICTSREFERENCE)
        INFO_USDICTTRANSLATION = getUSInfo(name: MUSMapping.NAME_USDICTTRANSLATION)
        INFO_USMACVOICE = getUSInfo(name: MUSMapping.NAME_USMACVOICE)
        INFO_USIOSVOICE = getUSInfo(name: MUSMapping.NAME_USIOSVOICE)
        return Observable.zip(MDictionary.getDictsReferenceByLang(USLANG),
                              MDictionary.getDictsNoteByLang(USLANG),
                              MDictionary.getDictsTranslationByLang(USLANG),
                              MTextbook.getDataByLang(USLANG),
                              MAutoCorrect.getDataByLang(USLANG),
                              MVoice.getDataByLang(USLANG))
            .flatMap { result -> Observable<()> in
                self.arrDictsReference = result.0
                self.selectedDictReference = self.arrDictsReference.first { String($0.DICTID) == self.USDICTREFERENCE }!
                self.selectedDictsReference = self.USDICTSREFERENCE.split(",").flatMap { id in self.arrDictsReference.filter { String($0.DICTID) == id } }
                self.arrDictsNote = result.1
                if self.arrDictsNote.isEmpty { self.arrDictsNote.append(MDictionary()) }
                self.selectedDictNote = self.arrDictsNote.first { $0.DICTID == self.USDICTNOTE } ?? self.arrDictsNote[0]
                self.arrDictsTranslation = result.2
                if self.arrDictsTranslation.isEmpty { self.arrDictsTranslation.append(MDictionary()) }
                self.selectedDictTranslation = self.arrDictsTranslation.first { $0.DICTID == self.USDICTTRANSLATION } ?? self.arrDictsTranslation[0]
                self.arrTextbooks = result.3
                self.selectedTextbook = self.arrTextbooks.first { $0.ID == self.USTEXTBOOK }!
                self.arrTextbookFilters = self.arrTextbooks.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) }
                self.arrTextbookFilters.insert(MSelectItem(value: 0, label: "All Textbooks"), at: 0)
                self.arrWebTextbookFilters = self.arrTextbooks.filter { $0.ISWEB == 1 }.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) }
                self.arrWebTextbookFilters.insert(MSelectItem(value: 0, label: "All Textbooks"), at: 0)
                self.arrAutoCorrect = result.4
                let arrVoices = result.5
                self.arrMacVoices = arrVoices.filter { $0.VOICETYPEID == 2 }
                if self.arrMacVoices.isEmpty { self.arrMacVoices.append(MVoice()) }
                self.arriOSVoices = arrVoices.filter { $0.VOICETYPEID == 3 }
                if self.arriOSVoices.isEmpty { self.arriOSVoices.append(MVoice()) }
                self.selectedMacVoice = self.arrMacVoices.first { $0.ID == self.USMACVOICE } ?? self.arrMacVoices[0]
                self.selectediOSVoice = self.arriOSVoices.first { $0.ID == self.USIOSVOICE } ?? self.arriOSVoices[0]
                if isinit {
                    self.delegate?.onUpdateLang()
                    return Observable.just(())
                } else {
                    return self.updateLang()
                }
            }
    }
    
    func updateLang() -> Observable<()> {
        MUserSetting.update(info: INFO_USLANG, intValue: USLANG).do(onNext: { self.delegate?.onUpdateLang() })
    }

    func updateTextbook() -> Observable<()> {
        MUserSetting.update(info: INFO_USTEXTBOOK, intValue: USTEXTBOOK).do(onNext: { self.delegate?.onUpdateTextbook() })
    }

    func updateDictReference() -> Observable<()> {
        MUserSetting.update(info: INFO_USDICTREFERENCE, stringValue: USDICTREFERENCE).do(onNext: { self.delegate?.onUpdateDictReference() })
    }
    
    func updateDictsReference() -> Observable<()> {
        MUserSetting.update(info: INFO_USDICTSREFERENCE, stringValue: USDICTSREFERENCE).do(onNext: { self.delegate?.onUpdateDictsReference() })
    }

    func updateDictNote() -> Observable<()> {
        MUserSetting.update(info: INFO_USDICTNOTE, intValue: USDICTNOTE).do(onNext: { self.delegate?.onUpdateDictNote() })
    }
    
    func updateDictTranslation() -> Observable<()> {
        MUserSetting.update(info: INFO_USDICTTRANSLATION, intValue: USDICTTRANSLATION).do(onNext: { self.delegate?.onUpdateDictTranslation() })
    }
    
    func updateMacVoice() -> Observable<()> {
        MUserSetting.update(info: INFO_USMACVOICE, intValue: USMACVOICE).do(onNext: { self.delegate?.onUpdateMacVoice() })
    }
    
    func updateiOSVoice() -> Observable<()> {
        MUserSetting.update(info: INFO_USIOSVOICE, intValue: USIOSVOICE).do(onNext: { self.delegate?.onUpdateiOSVoice() })
    }

    func autoCorrectInput(text: String) -> String {
        MAutoCorrect.autoCorrect(text: text, arrAutoCorrect: arrAutoCorrect, colFunc1: \.INPUT, colFunc2: \.EXTENDED)
    }
    
    func updateUnitFrom() -> Observable<()> {
        doUpdateUnitFrom(v: USUNITFROM, check: false).concat(
            toType == .unit ? doUpdateSingleUnit() :
            toType == .part || isInvalidUnitPart ? doUpdateUnitPartTo() :
            Observable.empty()
        )
    }
    
    func updatePartFrom() -> Observable<()> {
        doUpdatePartFrom(v: USPARTFROM, check: false).concat(
            toType == .part || isInvalidUnitPart ? doUpdateUnitPartTo() : Observable.empty()
        )
    }
    
    func updateUnitTo() -> Observable<()> {
        doUpdateUnitTo(v: USUNITTO, check: false).concat(
            isInvalidUnitPart ? doUpdateUnitPartFrom() : Observable.empty()
        )
    }
    
    func updatePartTo() -> Observable<()> {
        doUpdatePartTo(v: USPARTTO, check: false).concat(
            isInvalidUnitPart ? doUpdateUnitPartFrom() : Observable.empty()
        )
    }
    
    func updateToType() -> Observable<()> {
        toType == .unit ? doUpdateSingleUnit() :
            toType == .part ? doUpdateUnitPartTo() : Observable.empty()
    }
    
    func toggleToType(part: Int) -> Observable<()> {
        switch toType {
        case .unit:
            toType = .part
            return Observable.zip(doUpdatePartFrom(v: part), doUpdateUnitPartTo()).map{_ in }
        case .part:
            toType = .unit
            return doUpdateSingleUnit()
        default:
            return Observable.empty()
        }
    }

    func previousUnitPart() -> Observable<()> {
        if toType == .unit {
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
        if toType == .unit {
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
        Observable.zip(doUpdateUnitFrom(v: USUNITTO), doUpdatePartFrom(v: USPARTTO)).map{_ in }
    }
    
    private func doUpdateUnitPartTo() -> Observable<()> {
        Observable.zip(doUpdateUnitTo(v: USUNITFROM), doUpdatePartTo(v: USPARTFROM)).map{_ in }
    }
    
    private func doUpdateSingleUnit() -> Observable<()> {
        Observable.zip(doUpdateUnitTo(v: USUNITFROM), doUpdatePartFrom(v: 1), doUpdatePartTo(v: partCount)).map{_ in }
    }

    private func doUpdateUnitFrom(v: Int, check: Bool = true) -> Observable<()> {
        guard !check || USUNITFROM != v else { return Observable.empty() }
        USUNITFROM = v
        return MUserSetting.update(info: INFO_USUNITFROM, intValue: USUNITFROM).do(onNext: { self.delegate?.onUpdateUnitFrom() })
    }
    
    private func doUpdatePartFrom(v: Int, check: Bool = true) -> Observable<()> {
        guard !check || USPARTFROM != v else { return Observable.empty() }
        USPARTFROM = v
        return MUserSetting.update(info: INFO_USPARTFROM, intValue: USPARTFROM).do(onNext: { self.delegate?.onUpdatePartFrom()  })
    }
    
    private func doUpdateUnitTo(v: Int, check: Bool = true) -> Observable<()> {
        guard !check || USUNITTO != v else { return Observable.empty() }
        USUNITTO = v
        return MUserSetting.update(info: INFO_USUNITTO, intValue: USUNITTO).do(onNext: { self.delegate?.onUpdateUnitTo() })
    }
    
    private func doUpdatePartTo(v: Int, check: Bool = true) -> Observable<()> {
        guard !check || USPARTTO != v else { return Observable.empty() }
        USPARTTO = v
        return MUserSetting.update(info: INFO_USPARTTO, intValue: USPARTTO).do(onNext: { self.delegate?.onUpdatePartTo() })
    }
    
    static let zeroNote = "O"
    func getNote(word: String) -> Observable<String> {
        guard hasDictNote else { return Observable.empty() }
        let url = selectedDictNote.urlString(word: word, arrAutoCorrect: arrAutoCorrect)
        return RestApi.getHtml(url: url).map { html in
            print(html)
            return CommonApi.extractText(from: html, transform: self.selectedDictNote.TRANSFORM, template: "") { text,_ in text }
        }
    }
    
    func getNotes(wordCount: Int, isNoteEmpty: @escaping (Int) -> Bool, getOne: @escaping (Int) -> Void, allComplete: @escaping () -> Void) -> Disposable {
        guard hasDictNote else { return Observable<Any>.empty().subscribe() }
        var i = 0
        var subscription: Disposable?
        subscription = Observable<Int>.interval(.milliseconds(selectedDictNote.WAIT), scheduler: MainScheduler.instance).subscribe { _ in
                while i < wordCount && !isNoteEmpty(i) {
                    i += 1
                }
                if i > wordCount {
                    allComplete()
                    subscription?.dispose()
                } else {
                    if i < wordCount {
                        getOne(i)
                    }
                    // wait for the last one to finish
                    i += 1
                }
            }
        return subscription!
    }
    
    func clearNotes(wordCount: Int, isNoteEmpty: @escaping (Int) -> Bool, getOne: @escaping (Int) -> Observable<()>) -> Observable<()> {
        var i = 0
        var o = Observable.just(())
        while i < wordCount {
            while i < wordCount && !isNoteEmpty(i) {
                i += 1
            }
            if i < wordCount {
                o = o.concat(getOne(i))
            }
            i += 1
        }
        return o
    }
}

protocol SettingsViewModelDelegate : NSObjectProtocol {
    func onGetData()
    func onUpdateLang()
    func onUpdateDictReference()
    func onUpdateDictsReference()
    func onUpdateDictNote()
    func onUpdateDictTranslation()
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
    func onUpdateDictReference(){}
    func onUpdateDictsReference(){}
    func onUpdateDictNote(){}
    func onUpdateDictTranslation(){}
    func onUpdateTextbook(){}
    func onUpdateUnitFrom(){}
    func onUpdatePartFrom(){}
    func onUpdateUnitTo(){}
    func onUpdatePartTo(){}
    func onUpdateMacVoice(){}
    func onUpdateiOSVoice(){}
}
