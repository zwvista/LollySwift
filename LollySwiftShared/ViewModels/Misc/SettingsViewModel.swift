//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation
import Combine

@MainActor
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
    @Published var selectedLangIndex = -1
    var selectedLang: MLanguage { arrLanguages.indices ~= selectedLangIndex ? arrLanguages[selectedLangIndex] : MLanguage() }

    @Published var arrMacVoices = [MVoice]()
    @Published var arriOSVoices = [MVoice]()
    @Published var selectedMacVoiceIndex = -1
    var selectedMacVoice: MVoice { arrMacVoices.indices ~= selectedMacVoiceIndex ? arrMacVoices[selectedMacVoiceIndex] : MVoice() }
    var macVoiceName: String { selectedMacVoice.VOICENAME }
    @Published var selectediOSVoiceIndex = -1
    var selectediOSVoice: MVoice { arriOSVoices.indices ~= selectediOSVoiceIndex ? arriOSVoices[selectediOSVoiceIndex] : MVoice() }

    @Published var arrDictsReference = [MDictionary]()
    @Published var selectedDictReferenceIndex = -1
    var selectedDictReference: MDictionary { arrDictsReference.indices ~= selectedDictReferenceIndex ? arrDictsReference[selectedDictReferenceIndex] : MDictionary() }
    var selectedDictsReferenceIndexes = [Int]()
    var selectedDictsReference: [MDictionary] { selectedDictsReferenceIndexes.map { arrDictsReference[$0] } }
    
    @Published var arrDictsNote = [MDictionary]()
    @Published var selectedDictNoteIndex = -1
    var selectedDictNote: MDictionary { arrDictsNote.indices ~= selectedDictNoteIndex ? arrDictsNote[selectedDictNoteIndex] : MDictionary() }
    var hasDictNote: Bool { selectedDictNote.ID != 0 }
    
    @Published var arrDictsTranslation = [MDictionary]()
    @Published var selectedDictTranslationIndex = -1
    var selectedDictTranslation: MDictionary { arrDictsTranslation.indices ~= selectedDictTranslationIndex ? arrDictsTranslation[selectedDictTranslationIndex] : MDictionary() }
    var hasDictTranslation: Bool { selectedDictTranslation.ID != 0 }

    @Published var arrTextbooks = [MTextbook]()
    @Published var selectedTextbookIndex = -1
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

    @Published var selectedUnitFromIndex = -1
    var selectedUnitFrom: Int { arrUnits.indices ~= selectedUnitFromIndex ? arrUnits[selectedUnitFromIndex].value : 0 }
    @Published var selectedPartFromIndex = -1
    var selectedPartFrom: Int { arrParts.indices ~= selectedPartFromIndex ? arrParts[selectedPartFromIndex].value : 0 }
    @Published var selectedUnitToIndex = -1
    var selectedUnitTo: Int { arrUnits.indices ~= selectedUnitToIndex ? arrUnits[selectedUnitToIndex].value : 0 }
    @Published var selectedPartToIndex = -1
    var selectedPartTo: Int { arrParts.indices ~= selectedPartToIndex ? arrParts[selectedPartToIndex].value : 0 }

    @Published var toType_ = UnitPartToType.to.rawValue
    var toType: UnitPartToType {
        get { UnitPartToType(rawValue: toType_)! }
        set { toType_ = newValue.rawValue }
    }

    var toTypeMovable: Bool { toType == .to }
    @Published var toTypeTitle = ""
    @Published var unitToEnabled = false
    @Published var partToEnabled = false
    @Published var previousEnabled = false
    @Published var nextEnabled = false
    @Published var previousTitle = ""
    @Published var nextTitle = ""
    @Published var partFromEnabled = false

    static let arrToTypes = ["Unit", "Part", "To"]
    static let arrScopeWordFilters = ["Word", "Note"]
    static let arrScopePhraseFilters = ["Phrase", "Translation"]
    static let arrScopePatternFilters = ["Pattern", "Note", "Tags"]
    static let reviewModes = ["Review(Auto)", "Review(Manual)", "Test", "Textbook"]

    var arrAutoCorrect = [MAutoCorrect]()
    var arrDictTypes = [MCode]()
    
    weak var delegate: SettingsViewModelDelegate?

    var initialized = false

    var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        func onChange(_ source: Published<Int>.Publisher, _ selector: @escaping (Int) async -> Void) {
            source.removeDuplicates()
                .filter { self.initialized && $0 != -1 }
                .sink { n in Task { await selector(n) } }
                ~ subscriptions
        }

        onChange($selectedLangIndex) {
            print("selectedLangIndex=\($0)")
            await self.updateLang()
        }
        onChange($selectedMacVoiceIndex) {
            print("selectedMacVoiceIndex=\($0)")
            await self.updateMacVoice()
        }
        onChange($selectediOSVoiceIndex) {
            print("selectediOSVoiceIndex=\($0)")
            await self.updateiOSVoice()
        }
        onChange($selectedDictReferenceIndex) {
            print("selectedDictReferenceIndex=\($0)")
            await self.updateDictReference()
        }
        onChange($selectedDictNoteIndex) {
            print("selectedDictNoteIndex=\($0)")
            await self.updateDictNote()
        }
        onChange($selectedDictTranslationIndex) {
            print("selectedDictTranslationIndex=\($0)")
            await self.updateDictTranslation()
        }
        onChange($selectedTextbookIndex) {
            print("selectedTextbookIndex=\($0)")
            await self.updateTextbook()
        }
        onChange($selectedUnitFromIndex) {
            print("selectedUnitFromIndex=\($0)")
            await self.updateUnitFrom()
        }
        onChange($selectedPartFromIndex) {
            print("selectedPartFromIndex=\($0)")
            await self.updatePartFrom()
        }
        onChange($selectedUnitToIndex) {
            print("selectedUnitToIndex=\($0)")
            await self.updateUnitTo()
        }
        onChange($selectedPartToIndex) {
            print("selectedPartToIndex=\($0)")
            await self.updatePartTo()
        }

        $toType_.removeDuplicates()
            .sink { _ in Task { await self.updateToType() } }
            ~ subscriptions
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

    func getData() async {
        initialized = false
        async let task0 = MLanguage.getData()
        async let task1 = MUSMapping.getData()
        async let task2 = MUserSetting.getData()
        async let task3 = MCode.getData()
        (arrLanguages, arrUSMappings, arrUserSettings, arrDictTypes) = await (task0, task1, task2, task3)
        INFO_USLANG = getUSInfo(name: MUSMapping.NAME_USLANG)
        delegate?.onGetData()
        selectedLangIndex = arrLanguages.firstIndex { $0.ID == self.USLANG } ?? 0
        await updateLang()
        initialized = true
    }

    func updateLang() async {
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
        async let task0 = MDictionary.getDictsReferenceByLang(USLANG)
        async let task1 = MDictionary.getDictsNoteByLang(USLANG)
        async let task2 = MDictionary.getDictsTranslationByLang(USLANG)
        async let task3 = MTextbook.getDataByLang(USLANG, arrUserSettings: arrUserSettings)
        async let task4 = MAutoCorrect.getDataByLang(USLANG)
        async let task5 = MVoice.getDataByLang(USLANG)
        let arrVoices: [MVoice]
        (arrDictsReference, arrDictsNote, arrDictsTranslation, arrTextbooks, arrAutoCorrect, arrVoices) = await (task0, task1, task2, task3, task4, task5)
        selectedDictsReferenceIndexes = USDICTSREFERENCE.split(separator: ",").compactMap { id in arrDictsReference.firstIndex { String($0.DICTID) == id } }
        arrMacVoices = arrVoices.filter { $0.VOICETYPEID == 2 }
        if arrMacVoices.isEmpty { arrMacVoices.append(MVoice()) }
        arriOSVoices = arrVoices.filter { $0.VOICETYPEID == 3 }
        if arriOSVoices.isEmpty { arriOSVoices.append(MVoice()) }
        delegate?.onUpdateLang()
        selectedDictReferenceIndex = arrDictsReference.firstIndex { String($0.DICTID) == self.USDICTREFERENCE } ?? 0
        if arrDictsNote.isEmpty { arrDictsNote.append(MDictionary()) }
        selectedDictNoteIndex = arrDictsNote.firstIndex { $0.DICTID == self.USDICTNOTE } ?? 0
        if arrDictsTranslation.isEmpty { arrDictsTranslation.append(MDictionary()) }
        selectedDictTranslationIndex = arrDictsTranslation.firstIndex { $0.DICTID == self.USDICTTRANSLATION } ?? 0
        selectedTextbookIndex = arrTextbooks.firstIndex { $0.ID == self.USTEXTBOOK } ?? 0
        arrTextbookFilters = arrTextbooks.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) }
        arrTextbookFilters.insert(MSelectItem(value: 0, label: "All Textbooks"), at: 0)
        arrWebTextbookFilters = arrTextbooks.filter { $0.ISWEB == 1 }.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) }
        arrWebTextbookFilters.insert(MSelectItem(value: 0, label: "All Textbooks"), at: 0)
        selectedMacVoiceIndex = arrMacVoices.firstIndex { $0.ID == self.USMACVOICE } ?? 0
        selectediOSVoiceIndex = arriOSVoices.firstIndex { $0.ID == self.USIOSVOICE } ?? 0
        guard !initialized else {return}
        await withTaskGroup(of: Void.self) {
            $0.addTask { await self.updateTextbook() }
            $0.addTask { await self.updateDictReference() }
            $0.addTask { await self.updateDictsReference() }
            $0.addTask { await self.updateDictNote() }
            $0.addTask { await self.updateDictTranslation() }
            $0.addTask { await self.updateMacVoice() }
            $0.addTask { await self.updateiOSVoice() }
        }
        guard dirty else {return}
        await MUserSetting.update(info: INFO_USLANG, intValue: USLANG)
    }

    func updateTextbook() async {
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
        guard dirty else {return}
        await MUserSetting.update(info: INFO_USTEXTBOOK, intValue: USTEXTBOOK)
        guard dirty2 else {return}
        await updateToType()
    }

    func updateDictReference() async {
        let newVal = String(selectedDictReference.DICTID)
        if USDICTREFERENCE != newVal {
            USDICTREFERENCE = newVal
            await MUserSetting.update(info: INFO_USDICTREFERENCE, stringValue: USDICTREFERENCE)
        }
        delegate?.onUpdateDictReference()
    }

    func updateDictsReference() async {
        let newVal = selectedDictsReference.map { String($0.DICTID) }.joined(separator: ",")
        if USDICTSREFERENCE != newVal {
            USDICTSREFERENCE = newVal
            await MUserSetting.update(info: INFO_USDICTSREFERENCE, stringValue: USDICTSREFERENCE)
        }
        delegate?.onUpdateDictsReference()
    }

    func updateDictNote() async {
        let newVal = selectedDictNote.DICTID
        if USDICTNOTE != newVal {
            USDICTNOTE = newVal
            await MUserSetting.update(info: INFO_USDICTNOTE, intValue: USDICTNOTE)
        }
        delegate?.onUpdateDictNote()
    }

    func updateDictTranslation() async {
        let newVal = selectedDictTranslation.DICTID
        if USDICTTRANSLATION != newVal {
            USDICTTRANSLATION = newVal
            await MUserSetting.update(info: INFO_USDICTTRANSLATION, intValue: USDICTTRANSLATION)
        }
        delegate?.onUpdateDictTranslation()
    }

    func updateMacVoice() async {
        let newVal = selectedMacVoice.ID
        if USMACVOICE != newVal {
            USMACVOICE = newVal
            await MUserSetting.update(info: INFO_USMACVOICE, intValue: USMACVOICE)
        }
        delegate?.onUpdateMacVoice()
    }

    func updateiOSVoice() async {
        let newVal = selectediOSVoice.ID
        if USIOSVOICE != newVal {
            USIOSVOICE = newVal
            await MUserSetting.update(info: INFO_USIOSVOICE, intValue: USIOSVOICE)
        }
        delegate?.onUpdateiOSVoice()
    }

    func autoCorrectInput(text: String) -> String {
        MAutoCorrect.autoCorrect(text: text, arrAutoCorrect: arrAutoCorrect, colFunc1: \.INPUT, colFunc2: \.EXTENDED)
    }

    func updateUnitFrom() async {
        await doUpdateUnitFrom(v: selectedUnitFrom)
        if toType == .unit {
            await doUpdateSingleUnit()
        } else if toType == .part || isInvalidUnitPart {
            await doUpdateUnitPartTo()
        }
    }

    func updatePartFrom() async {
        await doUpdatePartFrom(v: selectedPartFrom)
        if toType == .part || isInvalidUnitPart {
            await doUpdateUnitPartTo()
        }
    }

    func updateUnitTo() async {
        await doUpdateUnitTo(v: selectedUnitTo)
        if isInvalidUnitPart {
            await doUpdateUnitPartFrom()
        }
    }

    func updatePartTo() async {
        await doUpdatePartTo(v: selectedPartTo)
        if isInvalidUnitPart {
            await doUpdateUnitPartFrom()
        }
    }

    func updateToType() async {
        print("toType=\(toType)")
        toTypeTitle = SettingsViewModel.arrToTypes[toType.rawValue]
        let b = toType == .to
        unitToEnabled = b
        partToEnabled = b && !isSinglePart
        previousEnabled = !b
        nextEnabled = !b
        let b2 = toType != .unit
        let t = !b2 ? "Unit" : "Part"
        previousTitle = "Previous " + t
        nextTitle = "Next " + t
        partFromEnabled = b2 && !isSinglePart
        if toType == .unit {
            await doUpdateSingleUnit()
        } else if toType == .part {
            await doUpdateUnitPartTo()
        }
    }

    func toggleToType(part: Int) async {
        switch toType {
        case .unit:
            toType = .part
            await withTaskGroup(of: Void.self) {
                $0.addTask { await self.doUpdatePartFrom(v: part) }
                $0.addTask { await self.doUpdateUnitPartTo() }
            }
        case .part:
            toType = .unit
            await doUpdateSingleUnit()
        default:
            break
        }
    }

    func previousUnitPart() async {
        if toType == .unit {
            let n = selectedUnitFrom
            if n > 1 {
                await withTaskGroup(of: Void.self) {
                    $0.addTask { await self.doUpdateUnitFrom(v: n - 1) }
                    $0.addTask { await self.doUpdateUnitTo(v: n - 1) }
                }
            }
        } else if selectedPartFrom > 1 {
            await withTaskGroup(of: Void.self) {
                $0.addTask { await self.doUpdatePartFrom(v: self.selectedPartFrom - 1) }
                $0.addTask { await self.doUpdateUnitPartTo() }
            }
        } else if selectedUnitFrom > 1 {
            await withTaskGroup(of: Void.self) {
                $0.addTask { await self.doUpdateUnitFrom(v: self.selectedUnitFrom - 1) }
                $0.addTask { await self.doUpdateUnitPartTo() }
            }
        }
    }

    func nextUnitPart() async {
        if toType == .unit {
            let n = selectedUnitFrom
            if n < unitCount {
                await withTaskGroup(of: Void.self) {
                    $0.addTask { await self.doUpdateUnitFrom(v: n + 1) }
                    $0.addTask { await self.doUpdateUnitTo(v: n + 1) }
                }
            }
        } else if selectedPartFrom < partCount {
            await withTaskGroup(of: Void.self) {
                $0.addTask { await self.doUpdatePartFrom(v: self.selectedPartFrom + 1) }
                $0.addTask { await self.doUpdateUnitPartTo() }
            }
        } else if selectedUnitFrom < unitCount {
            await withTaskGroup(of: Void.self) {
                $0.addTask { await self.doUpdateUnitFrom(v: self.selectedUnitFrom + 1) }
                $0.addTask { await self.doUpdateUnitPartTo() }
            }
        }
    }
    
    private func doUpdateUnitPartFrom() async {
        await withTaskGroup(of: Void.self) {
            $0.addTask { await self.doUpdateUnitFrom(v: self.USUNITTO) }
            $0.addTask { await self.doUpdatePartFrom(v: self.USPARTTO) }
        }
    }

    private func doUpdateUnitPartTo() async {
        await withTaskGroup(of: Void.self) {
            $0.addTask { await self.doUpdateUnitTo(v: self.USUNITFROM) }
            $0.addTask { await self.doUpdatePartTo(v: self.USPARTFROM) }
        }
    }

    private func doUpdateSingleUnit() async {
        await withTaskGroup(of: Void.self) {
            $0.addTask { await self.doUpdateUnitTo(v: self.USUNITFROM) }
            $0.addTask { await self.doUpdatePartFrom(v: 1) }
            $0.addTask { await self.doUpdatePartTo(v: self.partCount) }
        }
    }

    private func doUpdateUnitFrom(v: Int) async {
        guard USUNITFROM != v else {return}
        USUNITFROM = v
        selectedUnitFromIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        await MUserSetting.update(info: INFO_USUNITFROM, intValue: USUNITFROM)
        delegate?.onUpdateUnitFrom()
    }

    private func doUpdatePartFrom(v: Int) async {
        guard USPARTFROM != v else {return}
        USPARTFROM = v
        selectedPartFromIndex = arrParts.firstIndex { $0.value == v }
            ?? 0
        await MUserSetting.update(info: INFO_USPARTFROM, intValue: USPARTFROM)
        delegate?.onUpdatePartFrom()
    }

    private func doUpdateUnitTo(v: Int) async {
        guard USUNITTO != v else {return}
        USUNITTO = v
        selectedUnitToIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        await MUserSetting.update(info: INFO_USUNITTO, intValue: USUNITTO)
        delegate?.onUpdateUnitTo()
    }

    private func doUpdatePartTo(v: Int) async {
        guard USPARTTO != v else {return}
        USPARTTO = v
        selectedPartToIndex = arrParts.firstIndex { $0.value == v } ?? 0
        await MUserSetting.update(info: INFO_USPARTTO, intValue: USPARTTO)
        delegate?.onUpdatePartTo()
    }

    static let zeroNote = "O"
    func getNote(word: String) async -> String {
        guard hasDictNote else { return "" }
        let url = selectedDictNote.urlString(word: word, arrAutoCorrect: arrAutoCorrect)
        let html = await RestApi.getHtml(url: url)
        print(html)
        return CommonApi.extractText(from: html, transform: selectedDictNote.TRANSFORM, template: "") { text,_ in text }
    }

    func getNotes(wordCount: Int, isNoteEmpty: @escaping (Int) -> Bool, getOne: @escaping (Int) async -> Void, allComplete: @escaping () -> Void) async {
        guard hasDictNote else {return}
        var i = 0
        while true {
            while i < wordCount && !isNoteEmpty(i) {
                i += 1
            }
            if i > wordCount {
                allComplete()
                break
            } else {
                if i < wordCount {
                    await getOne(i)
                }
                // wait for the last one to finish
                i += 1
            }
            try! await Task.sleep(nanoseconds: UInt64(selectedDictNote.WAIT * 1_000_000))
        }
    }

    func clearNotes(wordCount: Int, isNoteEmpty: @escaping (Int) -> Bool, getOne: @escaping (Int) async -> Void) async {
        await withTaskGroup(of: Void.self) {
            var i = 0
            while i < wordCount {
                while i < wordCount && !isNoteEmpty(i) {
                    i += 1
                }
                if i < wordCount {
                    let j = i
                    $0.addTask { await getOne(j) }
                }
                i += 1
            }
        }
    }

    func getBlogContent() async -> String {
        (await MUnitBlog.getDataByTextbook(selectedTextbook.ID, unit: selectedUnitTo))?.CONTENT ?? ""
    }
    func saveBlogContent(content: String) async {
        await MUnitBlog.update(selectedTextbook.ID, unit: selectedUnitTo, content: content)
    }
}

@MainActor
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
