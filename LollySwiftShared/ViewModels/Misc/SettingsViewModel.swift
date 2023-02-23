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

enum UnitPartToType: Int {
    case unit
    case part
    case to
}

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
    var USUNITFROM: Int {
        get { Int(getUSValue(info: INFO_USUNITFROM)!)! }
        set { setUSValue(info: INFO_USUNITFROM, value: String(newValue)) }
    }
    var USUNITFROMSTR: String { selectedTextbook.UNITSTR(USUNITFROM) }
    private var INFO_USPARTFROM = MUserSettingInfo()
    var USPARTFROM: Int {
        get { Int(getUSValue(info: INFO_USPARTFROM)!)! }
        set { setUSValue(info: INFO_USPARTFROM, value: String(newValue)) }
    }
    var USPARTFROMSTR: String { selectedTextbook.PARTSTR(USPARTFROM) }
    private var INFO_USUNITTO = MUserSettingInfo()
    var USUNITTO: Int {
        get { Int(getUSValue(info: INFO_USUNITTO)!)! }
        set { setUSValue(info: INFO_USUNITTO, value: String(newValue)) }
    }
    var USUNITTOSTR: String { selectedTextbook.UNITSTR(USUNITTO) }
    private var INFO_USPARTTO = MUserSettingInfo()
    var USPARTTO: Int {
        get { Int(getUSValue(info: INFO_USPARTTO)!)! }
        set { setUSValue(info: INFO_USPARTTO, value: String(newValue)) }
    }
    var USPARTTOSTR: String { selectedTextbook.PARTSTR(USPARTTO) }
    var USUNITPARTFROM: Int { USUNITFROM * 10 + USPARTFROM }
    var USUNITPARTTO: Int { USUNITTO * 10 + USPARTTO }
    var isSingleUnitPart: Bool { USUNITPARTFROM == USUNITPARTTO }
    var isInvalidUnitPart: Bool { USUNITPARTFROM > USUNITPARTTO }

    var arrLanguages_ = BehaviorRelay(value: [MLanguage]())
    var arrLanguages: [MLanguage] { get { arrLanguages_.value } set { arrLanguages_.accept(newValue) } }
    var selectedLangIndex_ = BehaviorRelay(value: -1)
    var selectedLangIndex: Int { get { selectedLangIndex_.value } set { selectedLangIndex_.accept(newValue) } }
    var selectedLang: MLanguage { arrLanguages.indices ~= selectedLangIndex ? arrLanguages[selectedLangIndex] : MLanguage() }

    var arrMacVoices_ = BehaviorRelay(value: [MVoice]())
    var arrMacVoices: [MVoice] { get { arrMacVoices_.value } set { arrMacVoices_.accept(newValue) } }
    var arriOSVoices_ = BehaviorRelay(value: [MVoice]())
    var arriOSVoices: [MVoice] { get { arriOSVoices_.value } set { arriOSVoices_.accept(newValue) } }
    var selectedMacVoiceIndex_ = BehaviorRelay(value: -1)
    var selectedMacVoiceIndex: Int { get { selectedMacVoiceIndex_.value } set { selectedMacVoiceIndex_.accept(newValue) } }
    var selectedMacVoice: MVoice { arrMacVoices.indices ~= selectedMacVoiceIndex ? arrMacVoices[selectedMacVoiceIndex] : MVoice() }
    var macVoiceName: String { selectedMacVoice.VOICENAME }
    var selectediOSVoiceIndex_ = BehaviorRelay(value: -1)
    var selectediOSVoiceIndex: Int { get { selectediOSVoiceIndex_.value } set { selectediOSVoiceIndex_.accept(newValue) } }
    var selectediOSVoice: MVoice { arriOSVoices.indices ~= selectediOSVoiceIndex ? arriOSVoices[selectediOSVoiceIndex] : MVoice() }

    var arrDictsReference_ = BehaviorRelay(value: [MDictionary]())
    var arrDictsReference: [MDictionary] { get { arrDictsReference_.value } set { arrDictsReference_.accept(newValue) } }
    var selectedDictReferenceIndex_ = BehaviorRelay(value: -1)
    var selectedDictReferenceIndex: Int { get { selectedDictReferenceIndex_.value } set { selectedDictReferenceIndex_.accept(newValue) } }
    var selectedDictReference: MDictionary { arrDictsReference.indices ~= selectedDictReferenceIndex ? arrDictsReference[selectedDictReferenceIndex] : MDictionary() }
    var selectedDictsReferenceIndexes_ = BehaviorRelay(value: [Int]())
    var selectedDictsReferenceIndexes: [Int] { get { selectedDictsReferenceIndexes_.value } set { selectedDictsReferenceIndexes_.accept(newValue) } }
    var selectedDictsReference: [MDictionary] { selectedDictsReferenceIndexes.map { arrDictsReference[$0] } }

    var arrDictsNote_ = BehaviorRelay(value: [MDictionary]())
    var arrDictsNote: [MDictionary] { get { arrDictsNote_.value } set { arrDictsNote_.accept(newValue) } }
    var selectedDictNoteIndex_ = BehaviorRelay(value: -1)
    var selectedDictNoteIndex: Int { get { selectedDictNoteIndex_.value } set { selectedDictNoteIndex_.accept(newValue) } }
    var selectedDictNote: MDictionary { arrDictsNote.indices ~= selectedDictNoteIndex ? arrDictsNote[selectedDictNoteIndex] : MDictionary() }
    var hasDictNote: Bool { selectedDictNote.ID != 0 }

    var arrDictsTranslation_ = BehaviorRelay(value: [MDictionary]())
    var arrDictsTranslation: [MDictionary] { get { arrDictsTranslation_.value } set { arrDictsTranslation_.accept(newValue) } }
    var selectedDictTranslationIndex_ = BehaviorRelay(value: -1)
    var selectedDictTranslationIndex: Int { get { selectedDictTranslationIndex_.value } set { selectedDictTranslationIndex_.accept(newValue) } }
    var selectedDictTranslation: MDictionary { arrDictsTranslation.indices ~= selectedDictTranslationIndex ? arrDictsTranslation[selectedDictTranslationIndex] : MDictionary() }
    var hasDictTranslation: Bool { selectedDictTranslation.ID != 0 }

    var arrTextbooks_ = BehaviorRelay(value: [MTextbook]())
    var arrTextbooks: [MTextbook] { get { arrTextbooks_.value } set { arrTextbooks_.accept(newValue) } }
    var selectedTextbookIndex_ = BehaviorRelay(value: -1)
    var selectedTextbookIndex: Int { get { selectedTextbookIndex_.value } set { selectedTextbookIndex_.accept(newValue) } }
    var selectedTextbook: MTextbook { arrTextbooks.indices ~= selectedTextbookIndex ? arrTextbooks[selectedTextbookIndex] : MTextbook() }
    static let allBooksTextbookFilter = MSelectItem(value: 0, label: "All Textbooks")
    var arrTextbookFilters = [allBooksTextbookFilter]
    var arrWebTextbookFilters = [MSelectItem]()

    var arrUnits: [MSelectItem] { selectedTextbook.arrUnits }
    var unitCount: Int { arrUnits.count }
    var unitsInAll: String { "(\(unitCount) in all)" }
    var arrParts: [MSelectItem] { selectedTextbook.arrParts }
    var partCount: Int { arrParts.count }
    var isSingleUnit: Bool { USUNITFROM == USUNITTO && USPARTFROM == 1 && USPARTTO == partCount }
    var isSinglePart: Bool { partCount == 1 }
    var LANGINFO: String { "\(selectedLang.LANGNAME)" }
    var TEXTBOOKINFO: String { "\(LANGINFO) | \(selectedTextbook.TEXTBOOKNAME)" }
    var UNITINFO: String { "\(TEXTBOOKINFO) | \(USUNITFROMSTR) \(USPARTFROMSTR) ~ \(USUNITTOSTR) \(USPARTTOSTR)" }

    var selectedUnitFromIndex_ = BehaviorRelay(value: -1)
    var selectedUnitFromIndex: Int { get { selectedUnitFromIndex_.value } set { selectedUnitFromIndex_.accept(newValue) } }
    var selectedUnitFrom: Int { arrUnits.indices ~= selectedUnitFromIndex ? arrUnits[selectedUnitFromIndex].value : 0 }
    var selectedUnitFromText: String { arrUnits[selectedUnitFromIndex].label }
    var selectedPartFromIndex_ = BehaviorRelay(value: -1)
    var selectedPartFromIndex: Int { get { selectedPartFromIndex_.value } set { selectedPartFromIndex_.accept(newValue) } }
    var selectedPartFrom: Int { arrParts.indices ~= selectedPartFromIndex ? arrParts[selectedPartFromIndex].value : 0 }
    var selectedPartFromText: String { arrParts[selectedPartFromIndex].label }
    var selectedUnitToIndex_ = BehaviorRelay(value: -1)
    var selectedUnitToIndex: Int { get { selectedUnitToIndex_.value } set { selectedUnitToIndex_.accept(newValue) } }
    var selectedUnitTo: Int { arrUnits.indices ~= selectedUnitToIndex ? arrUnits[selectedUnitToIndex].value : 0 }
    var selectedUnitToText: String { arrUnits[selectedUnitToIndex].label }
    var selectedPartToIndex_ = BehaviorRelay(value: -1)
    var selectedPartToIndex: Int { get { selectedPartToIndex_.value } set { selectedPartToIndex_.accept(newValue) } }
    var selectedPartTo: Int { arrParts.indices ~= selectedPartToIndex ? arrParts[selectedPartToIndex].value : 0 }
    var selectedPartToText: String { arrParts[selectedPartToIndex].label }

    var toType_ = BehaviorRelay(value: UnitPartToType.to.rawValue)
    var toType: UnitPartToType {
        get { UnitPartToType(rawValue: toType_.value)! }
        set { toType_.accept(newValue.rawValue) }
    }

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
    var initialized = BehaviorRelay(value: false)

    override init() {
        super.init()

        func onChange(_ source: BehaviorRelay<Int>, _ selector: @escaping (Int) throws -> Single<()>) {
            source.distinctUntilChanged().filter { $0 != -1 }.flatMap(selector).subscribe() ~ rx.disposeBag
        }

        onChange(selectedLangIndex_) { [unowned self] n in
//            print("selectedLangIndex=\(n)")
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
            arrTextbookFilters = [SettingsViewModel.allBooksTextbookFilter]
            arrWebTextbookFilters = [SettingsViewModel.allBooksTextbookFilter]
            return Single.zip(MDictionary.getDictsReferenceByLang(USLANG),
                              MDictionary.getDictsNoteByLang(USLANG),
                              MDictionary.getDictsTranslationByLang(USLANG),
                              MTextbook.getDataByLang(USLANG, arrUserSettings: arrUserSettings),
                              MAutoCorrect.getDataByLang(USLANG),
                              MVoice.getDataByLang(USLANG))
                .flatMap { [unowned self] result in
                    arrDictsReference = result.0
                    selectedDictsReferenceIndexes = USDICTSREFERENCE.split(separator: ",").compactMap { id in arrDictsReference.firstIndex { String($0.DICTID) == id } }
                    arrDictsNote = result.1
                    arrDictsTranslation = result.2
                    arrTextbooks = result.3
                    arrAutoCorrect = result.4
                    let arrVoices = result.5
                    arrMacVoices = arrVoices.filter { $0.VOICETYPEID == 2 }
                    if arrMacVoices.isEmpty { arrMacVoices.append(MVoice()) }
                    arriOSVoices = arrVoices.filter { $0.VOICETYPEID == 3 }
                    if arriOSVoices.isEmpty { arriOSVoices.append(MVoice()) }
                    selectedDictReferenceIndex = arrDictsReference.firstIndex { String($0.DICTID) == USDICTREFERENCE } ?? 0
                    if arrDictsNote.isEmpty { arrDictsNote.append(MDictionary()) }
                    selectedDictNoteIndex = arrDictsNote.firstIndex { $0.DICTID == USDICTNOTE } ?? 0
                    if arrDictsTranslation.isEmpty { arrDictsTranslation.append(MDictionary()) }
                    selectedDictTranslationIndex = arrDictsTranslation.firstIndex { $0.DICTID == USDICTTRANSLATION } ?? 0
                    selectedTextbookIndex = arrTextbooks.firstIndex { $0.ID == USTEXTBOOK } ?? 0
                    arrTextbookFilters.append(contentsOf: arrTextbooks.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) })
                    arrWebTextbookFilters.append(contentsOf: arrTextbooks.filter { $0.ISWEB == 1 }.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) })
                    selectedMacVoiceIndex = arrMacVoices.firstIndex { $0.ID == USMACVOICE } ?? 0
                    selectediOSVoiceIndex = arriOSVoices.firstIndex { $0.ID == USIOSVOICE } ?? 0
                    return !dirty ? Single.just(()) : MUserSetting.update(info: INFO_USLANG, intValue: USLANG)
                }
        }

        onChange(selectedMacVoiceIndex_) { [unowned self] n in
//            print("selectedMacVoiceIndex=\(n)")
            let newVal = selectedMacVoice.ID
            let dirty = USMACVOICE != newVal
            USMACVOICE = newVal
            return !dirty ? Single.just(()) : MUserSetting.update(info: INFO_USMACVOICE, intValue: USMACVOICE)
        }

        onChange(selectediOSVoiceIndex_) { [unowned self] n in
//            print("selectediOSVoiceIndex=\(n)")
            let newVal = selectediOSVoice.ID
            let dirty = USIOSVOICE != newVal
            USIOSVOICE = newVal
            return !dirty ? Single.just(()) : MUserSetting.update(info: INFO_USIOSVOICE, intValue: USIOSVOICE)
        }

        onChange(selectedDictReferenceIndex_) { [unowned self] n in
//            print("selectedDictReferenceIndex=\(n)")
            let newVal = String(selectedDictReference.DICTID)
            let dirty = USDICTREFERENCE != newVal
            USDICTREFERENCE = newVal
            return !dirty ? Single.just(()) : MUserSetting.update(info: INFO_USDICTREFERENCE, stringValue: USDICTREFERENCE)
        }

        onChange(selectedDictNoteIndex_) { [unowned self] n in
//            print("selectedDictNoteIndex=\(n)")
            let newVal = selectedDictNote.DICTID
            let dirty = USDICTNOTE != newVal
            USDICTNOTE = newVal
            return !dirty ? Single.just(()) : MUserSetting.update(info: INFO_USDICTNOTE, intValue: USDICTNOTE)
        }

        onChange(selectedDictTranslationIndex_) { [unowned self] n in
//            print("selectedDictTranslationIndex=\(n)")
            let newVal = selectedDictTranslation.DICTID
            let dirty = USDICTTRANSLATION != newVal
            USDICTTRANSLATION = newVal
            return !dirty ? Single.just(()) : MUserSetting.update(info: INFO_USDICTTRANSLATION, intValue: USDICTTRANSLATION)
        }

        onChange(selectedTextbookIndex_) { [unowned self] n in
//            print("selectedTextbookIndex=\(n)")
            let newVal = selectedTextbook.ID
            let dirty = USTEXTBOOK != newVal
            USTEXTBOOK = newVal
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
            toType = isSingleUnit ? .unit : isSingleUnitPart ? .part : .to
            initialized.accept(true)
            return !dirty ? Single.just(()) : MUserSetting.update(info: INFO_USTEXTBOOK, intValue: USTEXTBOOK)
        }

        onChange(selectedUnitFromIndex_) { [unowned self] n in
//            print("selectedUnitFromIndex=\(n)")
            return doUpdateUnitFrom(v: selectedUnitFrom).flatMap { [unowned self] in
                toType == .unit ? doUpdateSingleUnit() :
                toType == .part || isInvalidUnitPart ? doUpdateUnitPartTo() :
                Single.just(())
            }
        }

        onChange(selectedPartFromIndex_) { [unowned self] n in
//            print("selectedPartFromIndex=\(n)")
            return doUpdatePartFrom(v: selectedPartFrom).flatMap { [unowned self] in
                toType == .part || isInvalidUnitPart ? doUpdateUnitPartTo() : Single.just(())
            }
        }

        onChange(selectedUnitToIndex_) { [unowned self] n in
//            print("selectedUnitToIndex=\(n)")
            return doUpdateUnitTo(v: selectedUnitTo).flatMap { [unowned self] in
                isInvalidUnitPart ? doUpdateUnitPartFrom() : Single.just(())
            }
        }

        onChange(selectedPartToIndex_) { [unowned self] n in
//            print("selectedPartToIndex=\(n)")
            return doUpdatePartTo(v: selectedPartTo).flatMap { [unowned self] in
                isInvalidUnitPart ? doUpdateUnitPartFrom() : Single.just(())
            }
        }

        toType_.distinctUntilChanged().flatMap { [unowned self] n in
//            print("toType=\(toType)")
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
        super.init()
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
        selectedLangIndex = -1
        return Single.zip(MLanguage.getData(),
                          MUSMapping.getData(),
                          MUserSetting.getData(),
                          MCode.getData())
            .map { [unowned self] result in
                arrLanguages = result.0
                arrUSMappings = result.1
                arrUserSettings = result.2
                arrDictTypes = result.3
                INFO_USLANG = getUSInfo(name: MUSMapping.NAME_USLANG)
                selectedLangIndex = arrLanguages.firstIndex { $0.ID == USLANG } ?? 0
            }
    }

    func updateDictsReference() -> Single<()> {
        let newVal = selectedDictsReference.map { String($0.DICTID) }.joined(separator: ",")
        let dirty = USDICTSREFERENCE != newVal
        USDICTSREFERENCE = newVal
        return !dirty ? Single.just(()) : MUserSetting.update(info: INFO_USDICTSREFERENCE, stringValue: USDICTSREFERENCE)
    }

    func autoCorrectInput(text: String) -> String {
        MAutoCorrect.autoCorrect(text: text, arrAutoCorrect: arrAutoCorrect, colFunc1: \.INPUT, colFunc2: \.EXTENDED)
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
        return MUserSetting.update(info: INFO_USUNITFROM, intValue: USUNITFROM)
    }

    private func doUpdatePartFrom(v: Int) -> Single<()> {
        let dirty = USPARTFROM != v
        if !dirty { return Single.just(()) }
        USPARTFROM = v
        selectedPartFromIndex = arrParts.firstIndex { $0.value == v } ?? 0
        return MUserSetting.update(info: INFO_USPARTFROM, intValue: USPARTFROM)
    }

    private func doUpdateUnitTo(v: Int) -> Single<()> {
        let dirty = USUNITTO != v
        if !dirty { return Single.just(()) }
        USUNITTO = v
        selectedUnitToIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        return MUserSetting.update(info: INFO_USUNITTO, intValue: USUNITTO)
    }

    private func doUpdatePartTo(v: Int) -> Single<()> {
        let dirty = USPARTTO != v
        if !dirty { return Single.just(()) }
        USPARTTO = v
        selectedPartToIndex = arrParts.firstIndex { $0.value == v } ?? 0
        return MUserSetting.update(info: INFO_USPARTTO, intValue: USPARTTO)
    }

    static let zeroNote = "O"
    func getNote(word: String) -> Single<String> {
        guard hasDictNote else { return Single.just("") }
        let url = selectedDictNote.urlString(word: word, arrAutoCorrect: arrAutoCorrect)
        return RestApi.getHtml(url: url).map { [unowned self] html in
            print(html)
            return CommonApi.extractText(from: html, transform: selectedDictNote.TRANSFORM, template: "") { text,_ in text }
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
