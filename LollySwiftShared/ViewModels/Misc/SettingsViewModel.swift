//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

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
        get { Int(getUSValue(info: INFO_USLANG)!)! }
        set { setUSValue(info: INFO_USLANG, value: String(newValue)) }
    }
    private var INFO_USTEXTBOOK = MUserSettingInfo()
    var USTEXTBOOK: Int {
        get { Int(getUSValue(info: INFO_USTEXTBOOK)!)! }
        set { setUSValue(info: INFO_USTEXTBOOK, value: String(newValue)) }
    }
    private var INFO_USDICTREFERENCE = MUserSettingInfo()
    var USDICTREFERENCE: String {
        get { getUSValue(info: INFO_USDICTREFERENCE)! }
        set { setUSValue(info: INFO_USDICTREFERENCE, value: newValue) }
    }
    private var INFO_USDICTNOTE = MUserSettingInfo()
    var USDICTNOTE: Int {
        get { Int(getUSValue(info: INFO_USDICTNOTE) ?? "") ?? 0 }
        set { setUSValue(info: INFO_USDICTNOTE, value: String(newValue) )}
    }
    private var INFO_USDICTSREFERENCE = MUserSettingInfo()
    var USDICTSREFERENCE: String {
        get { getUSValue(info: INFO_USDICTSREFERENCE) ?? "" }
        set { setUSValue(info: INFO_USDICTSREFERENCE, value: newValue) }
    }
    private var INFO_USDICTTRANSLATION = MUserSettingInfo()
    var USDICTTRANSLATION: Int {
        get { Int(getUSValue(info: INFO_USDICTTRANSLATION) ?? "") ?? 0 }
        set { setUSValue(info: INFO_USDICTTRANSLATION, value: String(newValue)) }
    }
    private var INFO_USMACVOICE = MUserSettingInfo()
    var USMACVOICE: Int {
        get { Int(getUSValue(info: INFO_USMACVOICE) ?? "") ?? 0 }
        set { setUSValue(info: INFO_USMACVOICE, value: String(newValue)) }
    }
    private var INFO_USIOSVOICE = MUserSettingInfo()
    var USIOSVOICE: Int {
        get { Int(getUSValue(info: INFO_USIOSVOICE) ?? "") ?? 0 }
        set { setUSValue(info: INFO_USIOSVOICE, value: String(newValue)) }
    }
    private var INFO_USUNITFROM = MUserSettingInfo()
    @objc
    var USUNITFROM: Int {
        get { Int(getUSValue(info: INFO_USUNITFROM)!)! }
        set { setUSValue(info: INFO_USUNITFROM, value: String(newValue)) }
    }
    var USUNITFROMSTR: String { selectedTextbook.UNITSTR(USUNITFROM) }
    private var INFO_USPARTFROM = MUserSettingInfo()
    @objc
    var USPARTFROM: Int {
        get { Int(getUSValue(info: INFO_USPARTFROM)!)! }
        set { setUSValue(info: INFO_USPARTFROM, value: String(newValue)) }
    }
    var USPARTFROMSTR: String { selectedTextbook.PARTSTR(USPARTFROM) }
    private var INFO_USUNITTO = MUserSettingInfo()
    @objc
    var USUNITTO: Int {
        get { Int(getUSValue(info: INFO_USUNITTO)!)! }
        set { setUSValue(info: INFO_USUNITTO, value: String(newValue)) }
    }
    var USUNITTOSTR: String { selectedTextbook.UNITSTR(USUNITTO) }
    private var INFO_USPARTTO = MUserSettingInfo()
    @objc
    var USPARTTO: Int {
        get { Int(getUSValue(info: INFO_USPARTTO)!)! }
        set { setUSValue(info: INFO_USPARTTO, value: String(newValue)) }
    }
    var USPARTTOSTR: String { selectedTextbook.PARTSTR(USPARTTO) }
    var USUNITPARTFROM: Int { USUNITFROM * 10 + USPARTFROM }
    var USUNITPARTTO: Int { USUNITTO * 10 + USPARTTO }
    var isSingleUnitPart: Bool { USUNITPARTFROM == USUNITPARTTO }
    var isInvalidUnitPart: Bool { USUNITPARTFROM > USUNITPARTTO }

    @Published var arrLanguages = [MLanguage]()
#if SWIFTUI
    @Published var selectedLangIndex = -1
#else
    var selectedLangIndex_ = BehaviorRelay(value: -1)
    var selectedLangIndex: Int { get { selectedLangIndex_.value } set { selectedLangIndex_.accept(newValue) } }
#endif
    var selectedLang: MLanguage { arrLanguages.indices ~= selectedLangIndex ? arrLanguages[selectedLangIndex] : MLanguage() }

    @Published var arrMacVoices = [MVoice]()
    @Published var arriOSVoices = [MVoice]()
#if SWIFTUI
    @Published var selectedMacVoiceIndex = -1
#else
    var selectedMacVoiceIndex_ = BehaviorRelay(value: -1)
    var selectedMacVoiceIndex: Int { get { selectedMacVoiceIndex_.value } set { selectedMacVoiceIndex_.accept(newValue) } }
#endif
    var selectedMacVoice: MVoice { arrMacVoices.indices ~= selectedMacVoiceIndex ? arrMacVoices[selectedMacVoiceIndex] : MVoice() }
    var macVoiceName: String { selectedMacVoice.VOICENAME }
#if SWIFTUI
    @Published var selectediOSVoiceIndex = -1
#else
    var selectediOSVoiceIndex_ = BehaviorRelay(value: -1)
    var selectediOSVoiceIndex: Int { get { selectediOSVoiceIndex_.value } set { selectediOSVoiceIndex_.accept(newValue) } }
#endif
    var selectediOSVoice: MVoice { arriOSVoices.indices ~= selectediOSVoiceIndex ? arriOSVoices[selectediOSVoiceIndex] : MVoice() }

    @Published var arrDictsReference = [MDictionary]()
#if SWIFTUI
    @Published var selectedDictReferenceIndex = -1
#else
    var selectedDictReferenceIndex_ = BehaviorRelay(value: -1)
    var selectedDictReferenceIndex: Int { get { selectedDictReferenceIndex_.value } set { selectedDictReferenceIndex_.accept(newValue) } }
#endif
    var selectedDictReference: MDictionary { arrDictsReference.indices ~= selectedDictReferenceIndex ? arrDictsReference[selectedDictReferenceIndex] : MDictionary() }
    var selectedDictsReferenceIndexes = [Int]()
    var selectedDictsReference: [MDictionary] { selectedDictsReferenceIndexes.map { arrDictsReference[$0] } }
    
    @Published var arrDictsNote = [MDictionary]()
#if SWIFTUI
    @Published var selectedDictNoteIndex = -1
#else
    var selectedDictNoteIndex_ = BehaviorRelay(value: -1)
    var selectedDictNoteIndex: Int { get { selectedDictNoteIndex_.value } set { selectedDictNoteIndex_.accept(newValue) } }
#endif
    var selectedDictNote: MDictionary { arrDictsNote.indices ~= selectedDictNoteIndex ? arrDictsNote[selectedDictNoteIndex] : MDictionary() }
    var hasDictNote: Bool { selectedDictNote.ID != 0 }
    
    @Published var arrDictsTranslation = [MDictionary]()
#if SWIFTUI
    @Published var selectedDictTranslationIndex = -1
#else
    var selectedDictTranslationIndex_ = BehaviorRelay(value: -1)
    var selectedDictTranslationIndex: Int { get { selectedDictTranslationIndex_.value } set { selectedDictTranslationIndex_.accept(newValue) } }
#endif
    var selectedDictTranslation: MDictionary { arrDictsTranslation.indices ~= selectedDictTranslationIndex ? arrDictsTranslation[selectedDictTranslationIndex] : MDictionary() }
    var hasDictTranslation: Bool { selectedDictTranslation.ID != 0 }

    @Published var arrTextbooks = [MTextbook]()
#if SWIFTUI
    @Published var selectedTextbookIndex = -1
#else
    var selectedTextbookIndex_ = BehaviorRelay(value: -1)
    var selectedTextbookIndex: Int { get { selectedTextbookIndex_.value } set { selectedTextbookIndex_.accept(newValue) } }
#endif
    var selectedTextbook: MTextbook { arrTextbooks.indices ~= selectedTextbookIndex ? arrTextbooks[selectedTextbookIndex] : MTextbook() }
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

#if SWIFTUI
    @Published var selectedUnitFromIndex = -1
#else
    var selectedUnitFromIndex_ = BehaviorRelay(value: -1)
    var selectedUnitFromIndex: Int { get { selectedUnitFromIndex_.value } set { selectedUnitFromIndex_.accept(newValue) } }
#endif
    var selectedUnitFrom: Int { arrUnits.indices ~= selectedUnitFromIndex ? arrUnits[selectedUnitFromIndex].value : 0 }
#if SWIFTUI
    @Published var selectedPartFromIndex = -1
#else
    var selectedPartFromIndex_ = BehaviorRelay(value: -1)
    var selectedPartFromIndex: Int { get { selectedPartFromIndex_.value } set { selectedPartFromIndex_.accept(newValue) } }
#endif
    var selectedPartFrom: Int { arrParts.indices ~= selectedPartFromIndex ? arrParts[selectedPartFromIndex].value : 0 }
#if SWIFTUI
    @Published var selectedUnitToIndex = -1
#else
    var selectedUnitToIndex_ = BehaviorRelay(value: -1)
    var selectedUnitToIndex: Int { get { selectedUnitToIndex_.value } set { selectedUnitToIndex_.accept(newValue) } }
#endif
    var selectedUnitTo: Int { arrUnits.indices ~= selectedUnitToIndex ? arrUnits[selectedUnitToIndex].value : 0 }
#if SWIFTUI
    @Published var selectedPartToIndex = -1
#else
    var selectedPartToIndex_ = BehaviorRelay(value: -1)
    var selectedPartToIndex: Int { get { selectedPartToIndex_.value } set { selectedPartToIndex_.accept(newValue) } }
#endif
    var selectedPartTo: Int { arrParts.indices ~= selectedPartToIndex ? arrParts[selectedPartToIndex].value : 0 }

    let arrToTypes = ["Unit", "Part", "To"]
    var toType: UnitPartToType = .to
    
    static let arrScopeWordFilters = ["Word", "Note"]
    static let arrScopePhraseFilters = ["Phrase", "Translation"]
    static let arrScopePatternFilters = ["Pattern", "Note", "Tags"]
    static let reviewModes = ["Review(Auto)", "Review(Manual)", "Test", "Textbook"]

    var arrAutoCorrect = [MAutoCorrect]()
    var arrDictTypes = [MCode]()
    
    weak var delegate: SettingsViewModelDelegate?
    
    override init() {
        super.init()
        selectedLangIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { _ -> Observable<()> in
            self.updateLang()
        }.subscribe() ~ rx.disposeBag
        selectedMacVoiceIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { _ -> Observable<()> in
            self.updateMacVoice()
        }.subscribe() ~ rx.disposeBag
        selectediOSVoiceIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { _ -> Observable<()> in
            self.updateiOSVoice()
        }.subscribe() ~ rx.disposeBag
        selectedDictReferenceIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { _ -> Observable<()> in
            self.updateDictReference()
        }.subscribe() ~ rx.disposeBag
        selectedDictNoteIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { _ -> Observable<()> in
            self.updateDictNote()
        }.subscribe() ~ rx.disposeBag
        selectedDictTranslationIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { _ -> Observable<()> in
            self.updateDictTranslation()
        }.subscribe() ~ rx.disposeBag
        selectedTextbookIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { _ -> Observable<()> in
            self.updateTextbook()
        }.subscribe() ~ rx.disposeBag
        selectedUnitFromIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { n -> Observable<()> in
            print("selectedUnitFromIndex=\(n)")
            return self.updateUnitFrom()
        }.subscribe() ~ rx.disposeBag
        selectedPartFromIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { n -> Observable<()> in
            print("selectedPartFromIndex=\(n)")
            return self.updatePartFrom()
        }.subscribe() ~ rx.disposeBag
        selectedUnitToIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { n -> Observable<()> in
            print("selectedUnitToIndex=\(n)")
            return self.updateUnitTo()
        }.subscribe() ~ rx.disposeBag
        selectedPartToIndex_.distinctUntilChanged().filter { $0 != -1 }.flatMap { n -> Observable<()> in
            print("selectedPartToIndex=\(n)")
            return self.updatePartTo()
        }.subscribe() ~ rx.disposeBag
    }

    init(_ x: SettingsViewModel) {
        arrUSMappings = x.arrUSMappings
        arrUserSettings = x.arrUserSettings
        INFO_USLANG = x.INFO_USLANG
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
        arrMacVoices = x.arrMacVoices
        arriOSVoices = x.arriOSVoices
        arrDictsReference = x.arrDictsReference
        selectedDictsReferenceIndexes = x.selectedDictsReferenceIndexes
        arrDictsNote = x.arrDictsNote
        arrDictsTranslation = x.arrDictsTranslation
        arrTextbooks = x.arrTextbooks
        arrTextbookFilters = x.arrTextbookFilters
        arrWebTextbookFilters = x.arrWebTextbookFilters
        toType = x.toType
        arrAutoCorrect = x.arrAutoCorrect
        arrDictTypes = x.arrDictTypes
        delegate = x.delegate
        super.init()
        selectedLangIndex = x.selectedLangIndex
        selectedMacVoiceIndex = x.selectedMacVoiceIndex
        selectediOSVoiceIndex = x.selectediOSVoiceIndex
        selectedDictReferenceIndex = x.selectedDictReferenceIndex
        selectedDictNoteIndex = x.selectedDictNoteIndex
        selectedDictTranslationIndex = x.selectedDictTranslationIndex
        selectedTextbookIndex = x.selectedTextbookIndex
        selectedUnitFromIndex = x.selectedUnitFromIndex
        selectedPartFromIndex = x.selectedPartFromIndex
        selectedUnitToIndex = x.selectedUnitToIndex
        selectedPartToIndex = x.selectedPartToIndex
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
                              MUserSetting.getData(),
                              MCode.getData())
            .flatMap { result -> Observable<()> in
                self.arrLanguages = result.0
                self.arrUSMappings = result.1
                self.arrUserSettings = result.2
                self.arrDictTypes = result.3
                self.INFO_USLANG = self.getUSInfo(name: MUSMapping.NAME_USLANG)
                self.delegate?.onGetData()
                self.selectedLangIndex = self.arrLanguages.firstIndex { $0.ID == self.USLANG } ?? 0
                return self.updateLang()
            }
    }

    func updateLang() -> Observable<()> {
        let newVal = selectedLang.ID
        let dirty = USLANG != newVal
        USLANG = newVal
        selectedDictReferenceIndex = -1
        selectedDictNoteIndex = -1
        selectedDictTranslationIndex = -1
        selectedTextbookIndex = -1
        selectedMacVoiceIndex = -1
        selectediOSVoiceIndex = -1
        delegate?.onUpdateLang()
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
                              MTextbook.getDataByLang(USLANG, arrUserSettings: arrUserSettings),
                              MAutoCorrect.getDataByLang(USLANG),
                              MVoice.getDataByLang(USLANG))
            .flatMap { result -> Observable<()> in
                self.arrDictsReference = result.0
                self.selectedDictReferenceIndex = self.arrDictsReference.firstIndex { String($0.DICTID) == self.USDICTREFERENCE } ?? 0
                self.selectedDictsReferenceIndexes = self.USDICTSREFERENCE.split(separator: ",").compactMap { id in self.arrDictsReference.firstIndex { String($0.DICTID) == id } }
                self.arrDictsNote = result.1
                if self.arrDictsNote.isEmpty { self.arrDictsNote.append(MDictionary()) }
                self.selectedDictNoteIndex = self.arrDictsNote.firstIndex { $0.DICTID == self.USDICTNOTE } ?? 0
                self.arrDictsTranslation = result.2
                if self.arrDictsTranslation.isEmpty { self.arrDictsTranslation.append(MDictionary()) }
                self.selectedDictTranslationIndex = self.arrDictsTranslation.firstIndex { $0.DICTID == self.USDICTTRANSLATION } ?? 0
                self.arrTextbooks = result.3
                self.selectedTextbookIndex = self.arrTextbooks.firstIndex { $0.ID == self.USTEXTBOOK } ?? 0
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
                self.selectedMacVoiceIndex = self.arrMacVoices.firstIndex { $0.ID == self.USMACVOICE } ?? 0
                self.selectediOSVoiceIndex = self.arriOSVoices.firstIndex { $0.ID == self.USIOSVOICE } ?? 0
                return Observable.zip(self.updateTextbook(), self.updateDictReference(), self.updateDictsReference(), self.updateDictNote(), self.updateDictTranslation(), self.updateMacVoice(), self.updateiOSVoice(), (!dirty ? Observable.just(()) : MUserSetting.update(info: self.INFO_USLANG, intValue: self.USLANG))).map {_ in }
            }
    }

    func updateTextbook() -> Observable<()> {
        let newVal = selectedTextbook.ID
        let dirty = USTEXTBOOK != newVal
        USTEXTBOOK = newVal
        selectedUnitToIndex = -1
        selectedPartFromIndex = -1
        selectedUnitToIndex = -1
        selectedPartToIndex = -1
        delegate?.onUpdateTextbook()
        INFO_USUNITFROM = getUSInfo(name: MUSMapping.NAME_USUNITFROM)
        INFO_USPARTFROM = getUSInfo(name: MUSMapping.NAME_USPARTFROM)
        INFO_USUNITTO = getUSInfo(name: MUSMapping.NAME_USUNITTO)
        INFO_USPARTTO = getUSInfo(name: MUSMapping.NAME_USPARTTO)
        selectedUnitFromIndex = arrUnits.firstIndex { $0.value == USUNITFROM } ?? 0
        selectedPartFromIndex = arrParts.firstIndex { $0.value == USPARTFROM } ?? 0
        selectedUnitToIndex = arrUnits.firstIndex { $0.value == USUNITTO } ?? 0
        selectedPartToIndex = arrParts.firstIndex { $0.value == USPARTTO } ?? 0
        toType = isSingleUnit ? .unit : isSingleUnitPart ? .part : .to
        return !dirty ? Observable.just(()) : MUserSetting.update(info: INFO_USTEXTBOOK, intValue: USTEXTBOOK)
    }

    func updateDictReference() -> Observable<()> {
        let newVal = String(selectedDictReference.DICTID)
        let dirty = USDICTREFERENCE != newVal
        USDICTREFERENCE = newVal
        return (!dirty ? Observable.just(()) : MUserSetting.update(info: INFO_USDICTREFERENCE, stringValue: USDICTREFERENCE)).do(onNext: { self.delegate?.onUpdateDictReference() })
    }
    
    func updateDictsReference() -> Observable<()> {
        let newVal = selectedDictsReference.map { String($0.DICTID) }.joined(separator: ",")
        let dirty = USDICTSREFERENCE != newVal
        USDICTSREFERENCE = newVal
        return (!dirty ? Observable.just(()) : MUserSetting.update(info: INFO_USDICTSREFERENCE, stringValue: USDICTSREFERENCE)).do(onNext: { self.delegate?.onUpdateDictsReference() })
    }

    func updateDictNote() -> Observable<()> {
        let newVal = selectedDictNote.DICTID
        let dirty = USDICTNOTE != newVal
        USDICTNOTE = newVal
        return (!dirty ? Observable.just(()) : MUserSetting.update(info: INFO_USDICTNOTE, intValue: USDICTNOTE)).do(onNext: { self.delegate?.onUpdateDictNote() })
    }
    
    func updateDictTranslation() -> Observable<()> {
        let newVal = selectedDictTranslation.DICTID
        let dirty = USDICTTRANSLATION != newVal
        USDICTTRANSLATION = newVal
        return (!dirty ? Observable.just(()) : MUserSetting.update(info: INFO_USDICTTRANSLATION, intValue: USDICTTRANSLATION)).do(onNext: { self.delegate?.onUpdateDictTranslation() })
    }
    
    func updateMacVoice() -> Observable<()> {
        let newVal = selectedMacVoice.ID
        let dirty = USMACVOICE != newVal
        USMACVOICE = newVal
        return (!dirty ? Observable.just(()) : MUserSetting.update(info: INFO_USMACVOICE, intValue: USMACVOICE)).do(onNext: { self.delegate?.onUpdateMacVoice() })
    }
    
    func updateiOSVoice() -> Observable<()> {
        let newVal = selectediOSVoice.ID
        let dirty = USIOSVOICE != newVal
        USIOSVOICE = newVal
        return (!dirty ? Observable.just(()) : MUserSetting.update(info: INFO_USIOSVOICE, intValue: USIOSVOICE)).do(onNext: { self.delegate?.onUpdateiOSVoice() })
    }

    func autoCorrectInput(text: String) -> String {
        MAutoCorrect.autoCorrect(text: text, arrAutoCorrect: arrAutoCorrect, colFunc1: \.INPUT, colFunc2: \.EXTENDED)
    }
    
    func updateUnitFrom() -> Observable<()> {
        doUpdateUnitFrom(v: selectedUnitFrom).concat(
            toType == .unit ? doUpdateSingleUnit() :
            toType == .part || isInvalidUnitPart ? doUpdateUnitPartTo() :
            Observable.empty()
        )
    }
    
    func updatePartFrom() -> Observable<()> {
        doUpdatePartFrom(v: selectedPartFrom).concat(
            toType == .part || isInvalidUnitPart ? doUpdateUnitPartTo() : Observable.empty()
        )
    }
    
    func updateUnitTo() -> Observable<()> {
        doUpdateUnitTo(v: selectedUnitTo).concat(
            isInvalidUnitPart ? doUpdateUnitPartFrom() : Observable.empty()
        )
    }
    
    func updatePartTo() -> Observable<()> {
        doUpdatePartTo(v: selectedPartTo).concat(
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
            return Observable.zip(doUpdatePartFrom(v: part), doUpdateUnitPartTo()).map {_ in }
        case .part:
            toType = .unit
            return doUpdateSingleUnit()
        default:
            return Observable.empty()
        }
    }

    func previousUnitPart() -> Observable<()> {
        if toType == .unit {
            let n = selectedUnitFrom
            if n > 1 {
                return Observable.zip(doUpdateUnitFrom(v: n - 1), doUpdateUnitTo(v: n - 1)).map {_ in }
            } else {
                return Observable.empty()
            }
        } else if selectedPartFrom > 1 {
            return Observable.zip(doUpdatePartFrom(v: selectedPartFrom - 1), doUpdateUnitPartTo()).map {_ in }
        } else if selectedUnitFrom > 1 {
            return Observable.zip(doUpdateUnitFrom(v: selectedUnitFrom - 1), doUpdatePartFrom(v: partCount), doUpdateUnitPartTo()).map {_ in }
        } else {
            return Observable.empty()
        }
    }
    
    func nextUnitPart() -> Observable<()> {
        if toType == .unit {
            let n = selectedUnitFrom
            if n < unitCount {
                return Observable.zip(doUpdateUnitFrom(v: n + 1), doUpdateUnitTo(v: n + 1)).map {_ in }
            } else {
                return Observable.empty()
            }
        } else if selectedPartFrom < partCount {
            return Observable.zip(doUpdatePartFrom(v: selectedPartFrom + 1), doUpdateUnitPartTo()).map {_ in }
        } else if selectedUnitFrom < unitCount {
            return Observable.zip(doUpdateUnitFrom(v: selectedUnitFrom + 1), doUpdatePartFrom(v: 1), doUpdateUnitPartTo()).map {_ in }
        } else {
            return Observable.empty()
        }
    }
    
    private func doUpdateUnitPartFrom() -> Observable<()> {
        Observable.zip(doUpdateUnitFrom(v: USUNITTO), doUpdatePartFrom(v: USPARTTO)).map {_ in }
    }
    
    private func doUpdateUnitPartTo() -> Observable<()> {
        Observable.zip(doUpdateUnitTo(v: USUNITFROM), doUpdatePartTo(v: USPARTFROM)).map {_ in }
    }
    
    private func doUpdateSingleUnit() -> Observable<()> {
        Observable.zip(doUpdateUnitTo(v: USUNITFROM), doUpdatePartFrom(v: 1), doUpdatePartTo(v: partCount)).map {_ in }
    }

    private func doUpdateUnitFrom(v: Int) -> Observable<()> {
        let dirty = USUNITFROM != v
        if !dirty { return Observable.empty() }
        USUNITFROM = v
        selectedUnitFromIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        return MUserSetting.update(info: INFO_USUNITFROM, intValue: USUNITFROM).do(onNext: { self.delegate?.onUpdateUnitFrom() })
    }
    
    private func doUpdatePartFrom(v: Int) -> Observable<()> {
        let dirty = USPARTFROM != v
        if !dirty { return Observable.empty() }
        USPARTFROM = v
        selectedPartFromIndex = arrParts.firstIndex { $0.value == v }
            ?? 0
        return MUserSetting.update(info: INFO_USPARTFROM, intValue: USPARTFROM).do(onNext: { self.delegate?.onUpdatePartFrom() })
    }
    
    private func doUpdateUnitTo(v: Int) -> Observable<()> {
        let dirty = USUNITTO != v
        if !dirty { return Observable.empty() }
        USUNITTO = v
        selectedUnitToIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        return MUserSetting.update(info: INFO_USUNITTO, intValue: USUNITTO).do(onNext: { self.delegate?.onUpdateUnitTo() })
    }
    
    private func doUpdatePartTo(v: Int) -> Observable<()> {
        let dirty = USPARTTO != v
        if !dirty { return Observable.empty() }
        USPARTTO = v
        selectedPartToIndex = arrParts.firstIndex { $0.value == v } ?? 0
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
