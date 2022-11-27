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
import RxBinding

class SettingsViewModel: NSObject {
    
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

    var arrLanguages = [MLanguage]()
    var selectedLangIndex_ = BehaviorRelay(value: -1)
    var selectedLangIndex: Int { get { selectedLangIndex_.value } set { selectedLangIndex_.accept(newValue) } }
    var selectedLang: MLanguage { arrLanguages.indices ~= selectedLangIndex ? arrLanguages[selectedLangIndex] : MLanguage() }

    var arrMacVoices = [MVoice]()
    var arriOSVoices = [MVoice]()
    var selectedMacVoiceIndex_ = BehaviorRelay(value: -1)
    var selectedMacVoiceIndex: Int { get { selectedMacVoiceIndex_.value } set { selectedMacVoiceIndex_.accept(newValue) } }
    var selectedMacVoice: MVoice { arrMacVoices.indices ~= selectedMacVoiceIndex ? arrMacVoices[selectedMacVoiceIndex] : MVoice() }
    var macVoiceName: String { selectedMacVoice.VOICENAME }
    var selectediOSVoiceIndex_ = BehaviorRelay(value: -1)
    var selectediOSVoiceIndex: Int { get { selectediOSVoiceIndex_.value } set { selectediOSVoiceIndex_.accept(newValue) } }
    var selectediOSVoice: MVoice { arriOSVoices.indices ~= selectediOSVoiceIndex ? arriOSVoices[selectediOSVoiceIndex] : MVoice() }

    var arrDictsReference = [MDictionary]()
    var selectedDictReferenceIndex_ = BehaviorRelay(value: -1)
    var selectedDictReferenceIndex: Int { get { selectedDictReferenceIndex_.value } set { selectedDictReferenceIndex_.accept(newValue) } }
    var selectedDictReference: MDictionary { arrDictsReference.indices ~= selectedDictReferenceIndex ? arrDictsReference[selectedDictReferenceIndex] : MDictionary() }
    var selectedDictsReferenceIndexes = [Int]()
    var selectedDictsReference: [MDictionary] { selectedDictsReferenceIndexes.map { arrDictsReference[$0] } }
    
    var arrDictsNote = [MDictionary]()
    var selectedDictNoteIndex_ = BehaviorRelay(value: -1)
    var selectedDictNoteIndex: Int { get { selectedDictNoteIndex_.value } set { selectedDictNoteIndex_.accept(newValue) } }
    var selectedDictNote: MDictionary { arrDictsNote.indices ~= selectedDictNoteIndex ? arrDictsNote[selectedDictNoteIndex] : MDictionary() }
    var hasDictNote: Bool { selectedDictNote.ID != 0 }
    
    var arrDictsTranslation = [MDictionary]()
    var selectedDictTranslationIndex_ = BehaviorRelay(value: -1)
    var selectedDictTranslationIndex: Int { get { selectedDictTranslationIndex_.value } set { selectedDictTranslationIndex_.accept(newValue) } }
    var selectedDictTranslation: MDictionary { arrDictsTranslation.indices ~= selectedDictTranslationIndex ? arrDictsTranslation[selectedDictTranslationIndex] : MDictionary() }
    var hasDictTranslation: Bool { selectedDictTranslation.ID != 0 }

    var arrTextbooks = [MTextbook]()
    var selectedTextbookIndex_ = BehaviorRelay(value: -1)
    var selectedTextbookIndex: Int { get { selectedTextbookIndex_.value } set { selectedTextbookIndex_.accept(newValue) } }
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

    var selectedUnitFromIndex_ = BehaviorRelay(value: -1)
    var selectedUnitFromIndex: Int { get { selectedUnitFromIndex_.value } set { selectedUnitFromIndex_.accept(newValue) } }
    var selectedUnitFrom: Int { arrUnits.indices ~= selectedUnitFromIndex ? arrUnits[selectedUnitFromIndex].value : 0 }
    var selectedPartFromIndex_ = BehaviorRelay(value: -1)
    var selectedPartFromIndex: Int { get { selectedPartFromIndex_.value } set { selectedPartFromIndex_.accept(newValue) } }
    var selectedPartFrom: Int { arrParts.indices ~= selectedPartFromIndex ? arrParts[selectedPartFromIndex].value : 0 }
    var selectedUnitToIndex_ = BehaviorRelay(value: -1)
    var selectedUnitToIndex: Int { get { selectedUnitToIndex_.value } set { selectedUnitToIndex_.accept(newValue) } }
    var selectedUnitTo: Int { arrUnits.indices ~= selectedUnitToIndex ? arrUnits[selectedUnitToIndex].value : 0 }
    var selectedPartToIndex_ = BehaviorRelay(value: -1)
    var selectedPartToIndex: Int { get { selectedPartToIndex_.value } set { selectedPartToIndex_.accept(newValue) } }
    var selectedPartTo: Int { arrParts.indices ~= selectedPartToIndex ? arrParts[selectedPartToIndex].value : 0 }

    var toType_ = BehaviorRelay(value: UnitPartToType.to.rawValue)
    var toType: UnitPartToType { get { UnitPartToType(rawValue: toType_.value)! } set { toType_.accept(newValue.rawValue) } }

    var toTypeMovable: Bool { toType == .to }
    var toTypeTitle = BehaviorRelay(value: "")
    var unitToEnabled = BehaviorRelay(value: false)
    var partToEnabled = BehaviorRelay(value: false)
    var previousEnabled = BehaviorRelay(value: false)
    var nextEnabled = BehaviorRelay(value: false)
    var previousTitle = BehaviorRelay(value: "")
    var nextTitle = BehaviorRelay(value: "")
    var partFromEnabled = BehaviorRelay(value: false)

    static let arrToTypes = ["Unit", "Part", "To"]
    static let arrScopeWordFilters = ["Word", "Note"]
    static let arrScopePhraseFilters = ["Phrase", "Translation"]
    static let arrScopePatternFilters = ["Pattern", "Note", "Tags"]
    static let reviewModes = ["Review(Auto)", "Review(Manual)", "Test", "Textbook"]

    var arrAutoCorrect = [MAutoCorrect]()
    var arrDictTypes = [MCode]()
    
    weak var delegate: SettingsViewModelDelegate?

    var initialized = false
    override init() {
        super.init()

#if !SWIFTUI
        func onChange(_ source: BehaviorRelay<Int>, _ selector: @escaping (Int) throws -> Single<()>) {
            source.distinctUntilChanged().filter { self.initialized && $0 != -1 }.flatMap(selector).subscribe() ~ rx.disposeBag
        }

        onChange(selectedLangIndex_) { n in
            print("selectedLangIndex=\(n)")
            return self.updateLang()
        }
        onChange(selectedMacVoiceIndex_) {n in
            print("selectedMacVoiceIndex=\(n)")
            return self.updateMacVoice()
        }
        onChange(selectediOSVoiceIndex_) {n in
            print("selectediOSVoiceIndex=\(n)")
            return self.updateiOSVoice()
        }
        onChange(selectedDictReferenceIndex_) {n in
            print("selectedDictReferenceIndex=\(n)")
            return self.updateDictReference()
        }
        onChange(selectedDictNoteIndex_) {n in
            print("selectedDictNoteIndex=\(n)")
            return self.updateDictNote()
        }
        onChange(selectedDictTranslationIndex_) {n in
            print("selectedDictTranslationIndex=\(n)")
            return self.updateDictTranslation()
        }
        onChange(selectedTextbookIndex_) {n in
            print("selectedTextbookIndex=\(n)")
            return self.updateTextbook()
        }
        onChange(selectedUnitFromIndex_) { n in
            print("selectedUnitFromIndex=\(n)")
            return self.updateUnitFrom()
        }
        onChange(selectedPartFromIndex_) { n in
            print("selectedPartFromIndex=\(n)")
            return self.updatePartFrom()
        }
        onChange(selectedUnitToIndex_) { n in
            print("selectedUnitToIndex=\(n)")
            return self.updateUnitTo()
        }
        onChange(selectedPartToIndex_) { n in
            print("selectedPartToIndex=\(n)")
            return self.updatePartTo()
        }

        toType_.distinctUntilChanged().flatMap { n -> Single<()> in
            return self.updateToType()
        }.subscribe() ~ rx.disposeBag
#endif
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
        toType = x.toType
        initialized = x.initialized
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

    func getData() -> Single<()> {
        initialized = false
        return Single.zip(MLanguage.getData(),
                              MUSMapping.getData(),
                              MUserSetting.getData(),
                              MCode.getData())
            .flatMap { result in
                self.arrLanguages = result.0
                self.arrUSMappings = result.1
                self.arrUserSettings = result.2
                self.arrDictTypes = result.3
                self.INFO_USLANG = self.getUSInfo(name: MUSMapping.NAME_USLANG)
                self.delegate?.onGetData()
                self.selectedLangIndex = self.arrLanguages.firstIndex { $0.ID == self.USLANG } ?? 0
                return self.initialized ? Single.just(()) : self.updateLang().do(onSuccess: { self.initialized = true })
            }
    }

    func updateLang() -> Single<()> {
        let newVal = selectedLang.ID
        let dirty = USLANG != newVal
        USLANG = newVal
        toType = .to
        selectedDictReferenceIndex = -1
        selectedDictNoteIndex = -1
        selectedDictTranslationIndex = -1
        selectedTextbookIndex = -1
        selectedMacVoiceIndex = -1
        selectediOSVoiceIndex = -1
        INFO_USTEXTBOOK = getUSInfo(name: MUSMapping.NAME_USTEXTBOOK)
        INFO_USDICTREFERENCE = getUSInfo(name: MUSMapping.NAME_USDICTREFERENCE)
        INFO_USDICTNOTE = getUSInfo(name: MUSMapping.NAME_USDICTNOTE)
        INFO_USDICTSREFERENCE = getUSInfo(name: MUSMapping.NAME_USDICTSREFERENCE)
        INFO_USDICTTRANSLATION = getUSInfo(name: MUSMapping.NAME_USDICTTRANSLATION)
        INFO_USMACVOICE = getUSInfo(name: MUSMapping.NAME_USMACVOICE)
        INFO_USIOSVOICE = getUSInfo(name: MUSMapping.NAME_USIOSVOICE)
        return Single.zip(MDictionary.getDictsReferenceByLang(USLANG),
                              MDictionary.getDictsNoteByLang(USLANG),
                              MDictionary.getDictsTranslationByLang(USLANG),
                              MTextbook.getDataByLang(USLANG, arrUserSettings: arrUserSettings),
                              MAutoCorrect.getDataByLang(USLANG),
                              MVoice.getDataByLang(USLANG))
            .flatMap { result in
                self.arrDictsReference = result.0
                self.selectedDictsReferenceIndexes = self.USDICTSREFERENCE.split(separator: ",").compactMap { id in self.arrDictsReference.firstIndex { String($0.DICTID) == id } }
                self.arrDictsNote = result.1
                self.arrDictsTranslation = result.2
                self.arrTextbooks = result.3
                self.arrAutoCorrect = result.4
                let arrVoices = result.5
                self.arrMacVoices = arrVoices.filter { $0.VOICETYPEID == 2 }
                if self.arrMacVoices.isEmpty { self.arrMacVoices.append(MVoice()) }
                self.arriOSVoices = arrVoices.filter { $0.VOICETYPEID == 3 }
                if self.arriOSVoices.isEmpty { self.arriOSVoices.append(MVoice()) }
                self.delegate?.onUpdateLang()
                self.selectedDictReferenceIndex = self.arrDictsReference.firstIndex { String($0.DICTID) == self.USDICTREFERENCE } ?? 0
                if self.arrDictsNote.isEmpty { self.arrDictsNote.append(MDictionary()) }
                self.selectedDictNoteIndex = self.arrDictsNote.firstIndex { $0.DICTID == self.USDICTNOTE } ?? 0
                if self.arrDictsTranslation.isEmpty { self.arrDictsTranslation.append(MDictionary()) }
                self.selectedDictTranslationIndex = self.arrDictsTranslation.firstIndex { $0.DICTID == self.USDICTTRANSLATION } ?? 0
                self.selectedTextbookIndex = self.arrTextbooks.firstIndex { $0.ID == self.USTEXTBOOK } ?? 0
                self.arrTextbookFilters = self.arrTextbooks.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) }
                self.arrTextbookFilters.insert(MSelectItem(value: 0, label: "All Textbooks"), at: 0)
                self.arrWebTextbookFilters = self.arrTextbooks.filter { $0.ISWEB == 1 }.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) }
                self.arrWebTextbookFilters.insert(MSelectItem(value: 0, label: "All Textbooks"), at: 0)
                self.selectedMacVoiceIndex = self.arrMacVoices.firstIndex { $0.ID == self.USMACVOICE } ?? 0
                self.selectediOSVoiceIndex = self.arriOSVoices.firstIndex { $0.ID == self.USIOSVOICE } ?? 0
                return Single.zip(self.initialized ? Single.just(()) : Single.zip(self.updateTextbook(), self.updateDictReference(), self.updateDictsReference(), self.updateDictNote(), self.updateDictTranslation(), self.updateMacVoice(), self.updateiOSVoice()).map { _ in }, (!dirty ? Single.just(()) : MUserSetting.update(info: self.INFO_USLANG, intValue: self.USLANG))).map { _ in }
            }
    }

    func updateTextbook() -> Single<()> {
        let newVal = selectedTextbook.ID
        let dirty = USTEXTBOOK != newVal
        USTEXTBOOK = newVal
        delegate?.onUpdateTextbook()
        selectedUnitFromIndex = -1
        selectedPartFromIndex = -1
        selectedUnitToIndex = -1
        selectedPartToIndex = -1
        INFO_USUNITFROM = getUSInfo(name: MUSMapping.NAME_USUNITFROM)
        INFO_USPARTFROM = getUSInfo(name: MUSMapping.NAME_USPARTFROM)
        INFO_USUNITTO = getUSInfo(name: MUSMapping.NAME_USUNITTO)
        INFO_USPARTTO = getUSInfo(name: MUSMapping.NAME_USPARTTO)
        selectedUnitFromIndex = arrUnits.firstIndex { $0.value == USUNITFROM } ?? 0
        selectedPartFromIndex = arrParts.firstIndex { $0.value == USPARTFROM } ?? 0
        selectedUnitToIndex = arrUnits.firstIndex { $0.value == USUNITTO } ?? 0
        selectedPartToIndex = arrParts.firstIndex { $0.value == USPARTTO } ?? 0
        let newVal2: UnitPartToType = isSingleUnit ? .unit : isSingleUnitPart ? .part : .to
        let dirty2 = newVal2 != toType
        toType = newVal2
        return (!dirty ? Single.just(()) : MUserSetting.update(info: INFO_USTEXTBOOK, intValue: USTEXTBOOK)).flatMap {
            dirty2 ? Single.just(()) : self.updateToType()
        }
    }

    func updateDictReference() -> Single<()> {
        let newVal = String(selectedDictReference.DICTID)
        let dirty = USDICTREFERENCE != newVal
        USDICTREFERENCE = newVal
        return (!dirty ? Single.just(()) : MUserSetting.update(info: INFO_USDICTREFERENCE, stringValue: USDICTREFERENCE)).do(onSuccess: { self.delegate?.onUpdateDictReference() })
    }

    func updateDictsReference() -> Single<()> {
        let newVal = selectedDictsReference.map { String($0.DICTID) }.joined(separator: ",")
        let dirty = USDICTSREFERENCE != newVal
        USDICTSREFERENCE = newVal
        return (!dirty ? Single.just(()) : MUserSetting.update(info: INFO_USDICTSREFERENCE, stringValue: USDICTSREFERENCE)).do(onSuccess: { self.delegate?.onUpdateDictsReference() })
    }

    func updateDictNote() -> Single<()> {
        let newVal = selectedDictNote.DICTID
        let dirty = USDICTNOTE != newVal
        USDICTNOTE = newVal
        return (!dirty ? Single.just(()) : MUserSetting.update(info: INFO_USDICTNOTE, intValue: USDICTNOTE)).do(onSuccess: { self.delegate?.onUpdateDictNote() })
    }

    func updateDictTranslation() -> Single<()> {
        let newVal = selectedDictTranslation.DICTID
        let dirty = USDICTTRANSLATION != newVal
        USDICTTRANSLATION = newVal
        return (!dirty ? Single.just(()) : MUserSetting.update(info: INFO_USDICTTRANSLATION, intValue: USDICTTRANSLATION)).do(onSuccess: { self.delegate?.onUpdateDictTranslation() })
    }

    func updateMacVoice() -> Single<()> {
        let newVal = selectedMacVoice.ID
        let dirty = USMACVOICE != newVal
        USMACVOICE = newVal
        return (!dirty ? Single.just(()) : MUserSetting.update(info: INFO_USMACVOICE, intValue: USMACVOICE)).do(onSuccess: { self.delegate?.onUpdateMacVoice() })
    }

    func updateiOSVoice() -> Single<()> {
        let newVal = selectediOSVoice.ID
        let dirty = USIOSVOICE != newVal
        USIOSVOICE = newVal
        return (!dirty ? Single.just(()) : MUserSetting.update(info: INFO_USIOSVOICE, intValue: USIOSVOICE)).do(onSuccess: { self.delegate?.onUpdateiOSVoice() })
    }

    func autoCorrectInput(text: String) -> String {
        MAutoCorrect.autoCorrect(text: text, arrAutoCorrect: arrAutoCorrect, colFunc1: \.INPUT, colFunc2: \.EXTENDED)
    }

    func updateUnitFrom() -> Single<()> {
        doUpdateUnitFrom(v: selectedUnitFrom).flatMap {
            self.toType == .unit ? self.doUpdateSingleUnit() :
            self.toType == .part || self.isInvalidUnitPart ? self.doUpdateUnitPartTo() :
            Single.just(())
        }
    }

    func updatePartFrom() -> Single<()> {
        doUpdatePartFrom(v: selectedPartFrom).flatMap {
            self.toType == .part || self.isInvalidUnitPart ? self.doUpdateUnitPartTo() : Single.just(())
        }
    }

    func updateUnitTo() -> Single<()> {
        doUpdateUnitTo(v: selectedUnitTo).flatMap {
            self.isInvalidUnitPart ? self.doUpdateUnitPartFrom() : Single.just(())
        }
    }

    func updatePartTo() -> Single<()> {
        doUpdatePartTo(v: selectedPartTo).flatMap {
            self.isInvalidUnitPart ? self.doUpdateUnitPartFrom() : Single.just(())
        }
    }

    func updateToType() -> Single<()> {
        print("toType=\(toType)")
        toTypeTitle.accept(SettingsViewModel.arrToTypes[toType_.value])
        let b = toType == .to
        unitToEnabled.accept(b)
        partToEnabled.accept(b && !isSinglePart)
        previousEnabled.accept(!b)
        nextEnabled.accept(!b)
        let b2 = toType != .unit
        let t = !b2 ? "Unit" : "Part"
        previousTitle.accept("Previous " + t)
        nextTitle.accept("Next " + t)
        partFromEnabled.accept(b2 && !isSinglePart)
        return toType == .unit ? doUpdateSingleUnit() :
        toType == .part ? doUpdateUnitPartTo() : Single.just(())
    }

    func toggleToType(part: Int) -> Single<()> {
        switch toType {
        case .unit:
            toType = .part
            return Single.zip(doUpdatePartFrom(v: part), doUpdateUnitPartTo()).map { _ in }
        case .part:
            toType = .unit
            return doUpdateSingleUnit()
        default:
            return Single.just(())
        }
    }

    func previousUnitPart() -> Single<()> {
        if toType == .unit {
            let n = selectedUnitFrom
            if n > 1 {
                return Single.zip(doUpdateUnitFrom(v: n - 1), doUpdateUnitTo(v: n - 1)).map { _ in }
            } else {
                return Single.just(())
            }
        } else if selectedPartFrom > 1 {
            return Single.zip(doUpdatePartFrom(v: selectedPartFrom - 1), doUpdateUnitPartTo()).map { _ in }
        } else if selectedUnitFrom > 1 {
            return Single.zip(doUpdateUnitFrom(v: selectedUnitFrom - 1), doUpdatePartFrom(v: partCount), doUpdateUnitPartTo()).map { _ in }
        } else {
            return Single.just(())
        }
    }

    func nextUnitPart() -> Single<()> {
        if toType == .unit {
            let n = selectedUnitFrom
            if n < unitCount {
                return Single.zip(doUpdateUnitFrom(v: n + 1), doUpdateUnitTo(v: n + 1)).map { _ in }
            } else {
                return Single.just(())
            }
        } else if selectedPartFrom < partCount {
            return Single.zip(doUpdatePartFrom(v: selectedPartFrom + 1), doUpdateUnitPartTo()).map { _ in }
        } else if selectedUnitFrom < unitCount {
            return Single.zip(doUpdateUnitFrom(v: selectedUnitFrom + 1), doUpdatePartFrom(v: 1), doUpdateUnitPartTo()).map { _ in }
        } else {
            return Single.just(())
        }
    }
    
    private func doUpdateUnitPartFrom() -> Single<()> {
        Single.zip(doUpdateUnitFrom(v: USUNITTO), doUpdatePartFrom(v: USPARTTO)).map { _ in }
    }

    private func doUpdateUnitPartTo() -> Single<()> {
        Single.zip(doUpdateUnitTo(v: USUNITFROM), doUpdatePartTo(v: USPARTFROM)).map { _ in }
    }

    private func doUpdateSingleUnit() -> Single<()> {
        Single.zip(doUpdateUnitTo(v: USUNITFROM), doUpdatePartFrom(v: 1), doUpdatePartTo(v: partCount)).map { _ in }
    }

    private func doUpdateUnitFrom(v: Int) -> Single<()> {
        let dirty = USUNITFROM != v
        if !dirty { return Single.just(()) }
        USUNITFROM = v
        selectedUnitFromIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        return MUserSetting.update(info: INFO_USUNITFROM, intValue: USUNITFROM).do(onSuccess: { self.delegate?.onUpdateUnitFrom() })
    }

    private func doUpdatePartFrom(v: Int) -> Single<()> {
        let dirty = USPARTFROM != v
        if !dirty { return Single.just(()) }
        USPARTFROM = v
        selectedPartFromIndex = arrParts.firstIndex { $0.value == v }
            ?? 0
        return MUserSetting.update(info: INFO_USPARTFROM, intValue: USPARTFROM).do(onSuccess: { self.delegate?.onUpdatePartFrom() })
    }

    private func doUpdateUnitTo(v: Int) -> Single<()> {
        let dirty = USUNITTO != v
        if !dirty { return Single.just(()) }
        USUNITTO = v
        selectedUnitToIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        return MUserSetting.update(info: INFO_USUNITTO, intValue: USUNITTO).do(onSuccess: { self.delegate?.onUpdateUnitTo() })
    }

    private func doUpdatePartTo(v: Int) -> Single<()> {
        let dirty = USPARTTO != v
        if !dirty { return Single.just(()) }
        USPARTTO = v
        selectedPartToIndex = arrParts.firstIndex { $0.value == v } ?? 0
        return MUserSetting.update(info: INFO_USPARTTO, intValue: USPARTTO).do(onSuccess: { self.delegate?.onUpdatePartTo() })
    }

    static let zeroNote = "O"
    func getNote(word: String) -> Single<String> {
        guard hasDictNote else { return Single.just("") }
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

    func clearNotes(wordCount: Int, isNoteEmpty: @escaping (Int) -> Bool, getOne: @escaping (Int) -> Single<()>) -> Single<()> {
        var i = 0
        var o = Single.just(())
        while i < wordCount {
            while i < wordCount && !isNoteEmpty(i) {
                i += 1
            }
            if i < wordCount {
                let j = i
                o = o.flatMap { getOne(j) }
            }
            i += 1
        }
        return o
    }

    func getBlogContent() -> Single<String> {
        MUnitBlog.getDataByTextbook(selectedTextbook.ID, unit: selectedUnitTo).map {
            $0?.CONTENT ?? ""
        }
    }
    func saveBlogContent(content: String) -> Single<()> {
        MUnitBlog.update(selectedTextbook.ID, unit: selectedUnitTo, content: content)
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
