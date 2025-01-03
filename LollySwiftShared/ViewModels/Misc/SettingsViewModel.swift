//
//  SettingsViewModel.swift
//  LollySwiftShared
//
//  Created by zhaowei on 2014/11/07.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import Foundation
import Combine

enum UnitPartToType: Int, CaseIterable, Identifiable {
    case unit
    case part
    case to

    var id: Int { self.rawValue }
}

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
    @Published var selectedDictsReferenceIndexes = [Int]()
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
    static let allBooksTextbookFilter = MSelectItem(value: 0, label: "All Textbooks")
    var arrTextbookFilters = [allBooksTextbookFilter]
    var arrOnlineTextbookFilters = [MSelectItem]()

    var arrUnits: [MSelectItem] { selectedTextbook.arrUnits }
    var unitCount: Int { arrUnits.count }
    var unitsInAll: String { "(\(unitCount) in all)" }
    var arrParts: [MSelectItem] { selectedTextbook.arrParts }
    var partCount: Int { arrParts.count }
    var isSingleUnit: Bool { USUNITFROM == USUNITTO && USPARTFROM == 1 && USPARTTO == partCount }
    var isSinglePart: Bool { partCount == 1 }
    var LANGINFO: String { "\(selectedLang.LANGNAME)" }
    var TEXTBOOKINFO: String { "\(LANGINFO) | \(selectedTextbook.TEXTBOOKNAME)" }
    var UNITPARTINFO: String { "\(TEXTBOOKINFO) | \(USUNITFROMSTR) \(USPARTFROMSTR) ~ \(USUNITTOSTR) \(USPARTTOSTR)" }
    var BLOGUNITINFO: String { "\(TEXTBOOKINFO) | \(USUNITTOSTR) \(selectedTextbook.arrParts.first!.label) ~ \(USUNITTOSTR) \(selectedTextbook.arrParts.last!.label)" }

    @Published var selectedUnitFromIndex = -1
    var selectedUnitFrom: Int { arrUnits.indices ~= selectedUnitFromIndex ? arrUnits[selectedUnitFromIndex].value : 0 }
    var selectedUnitFromText: String { arrUnits[selectedUnitFromIndex].label }
    @Published var selectedPartFromIndex = -1
    var selectedPartFrom: Int { arrParts.indices ~= selectedPartFromIndex ? arrParts[selectedPartFromIndex].value : 0 }
    var selectedPartFromText: String { arrParts[selectedPartFromIndex].label }
    @Published var selectedUnitToIndex = -1
    var selectedUnitTo: Int { arrUnits.indices ~= selectedUnitToIndex ? arrUnits[selectedUnitToIndex].value : 0 }
    var selectedUnitToText: String { arrUnits[selectedUnitToIndex].label }
    @Published var selectedPartToIndex = -1
    var selectedPartTo: Int { arrParts.indices ~= selectedPartToIndex ? arrParts[selectedPartToIndex].value : 0 }
    var selectedPartToText: String { arrParts[selectedPartToIndex].label }

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

    nonisolated static let arrToTypes = ["Unit", "Part", "To"]
    nonisolated static let arrScopeWordFilters = ["Word", "Note"]
    nonisolated static let arrScopePhraseFilters = ["Phrase", "Translation"]
    nonisolated static let arrScopePatternFilters = ["Pattern", "Tags"]
    nonisolated static let reviewModes = ["Review(Auto)", "Review(Manual)", "Test", "Textbook"]

    var arrAutoCorrect = [MAutoCorrect]()
    var arrDictTypes = [MCode]()
    @Published var initialized = false
    var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        func onChange(_ source: Published<Int>.Publisher, _ selector: @escaping (Int) async -> Void) {
            source.didSet.removeDuplicates()
                .filter { $0 != -1 }
                .sink { n in Task { await selector(n) } }
                ~ subscriptions
        }

        onChange($selectedLangIndex) { [unowned self] n in
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
            arrOnlineTextbookFilters = [SettingsViewModel.allBooksTextbookFilter]
            let uslang = USLANG
            let arrUserSettings = arrUserSettings
            async let res1 = MDictionary.getDictsReferenceByLang(uslang)
            async let res2 = MDictionary.getDictsNoteByLang(uslang)
            async let res3 = MDictionary.getDictsTranslationByLang(uslang)
            async let res4 = MTextbook.getDataByLang(uslang, arrUserSettings: arrUserSettings)
            async let res5 = MAutoCorrect.getDataByLang(uslang)
            async let res6 = MVoice.getDataByLang(uslang)
            let arrVoices: [MVoice]
            (arrDictsReference, arrDictsNote, arrDictsTranslation, arrTextbooks, arrAutoCorrect, arrVoices) = await (res1, res2, res3, res4, res5, res6)
            selectedDictsReferenceIndexes = USDICTSREFERENCE.split(separator: ",").compactMap { id in arrDictsReference.firstIndex { String($0.DICTID) == id } }
            arrMacVoices = arrVoices.filter { $0.VOICETYPEID == 2 }
            if arrMacVoices.isEmpty { arrMacVoices.append(MVoice()) }
            arriOSVoices = arrVoices.filter { $0.VOICETYPEID == 3 }
            if arriOSVoices.isEmpty { arriOSVoices.append(MVoice()) }
            selectedMacVoiceIndex = arrMacVoices.firstIndex { $0.ID == USMACVOICE } ?? 0
            selectediOSVoiceIndex = arriOSVoices.firstIndex { $0.ID == USIOSVOICE } ?? 0
            selectedDictReferenceIndex = arrDictsReference.firstIndex { String($0.DICTID) == USDICTREFERENCE } ?? 0
            if arrDictsNote.isEmpty { arrDictsNote.append(MDictionary()) }
            selectedDictNoteIndex = arrDictsNote.firstIndex { $0.DICTID == USDICTNOTE } ?? 0
            if arrDictsTranslation.isEmpty { arrDictsTranslation.append(MDictionary()) }
            selectedDictTranslationIndex = arrDictsTranslation.firstIndex { $0.DICTID == USDICTTRANSLATION } ?? 0
            selectedTextbookIndex = arrTextbooks.firstIndex { $0.ID == USTEXTBOOK } ?? 0
            arrTextbookFilters.append(contentsOf: arrTextbooks.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) })
            arrOnlineTextbookFilters.append(contentsOf: arrTextbooks.filter { $0.ONLINE == 1 }.map { MSelectItem(value: $0.ID, label: $0.TEXTBOOKNAME) })
            if dirty {
                await MUserSetting.update(info: INFO_USLANG, intValue: USLANG)
            }
        }

        onChange($selectedMacVoiceIndex) { [unowned self] n in
//            print("selectedMacVoiceIndex=\(n)")
            let newVal = selectedMacVoice.ID
            if USMACVOICE != newVal {
                USMACVOICE = newVal
                await MUserSetting.update(info: INFO_USMACVOICE, intValue: USMACVOICE)
            }
        }

        onChange($selectediOSVoiceIndex) { [unowned self] n in
//            print("selectediOSVoiceIndex=\(n)")
            let newVal = selectediOSVoice.ID
            if USIOSVOICE != newVal {
                USIOSVOICE = newVal
                await MUserSetting.update(info: INFO_USIOSVOICE, intValue: USIOSVOICE)
            }
        }

        onChange($selectedDictReferenceIndex) { [unowned self] n in
//            print("selectedDictReferenceIndex=\(n)")
            let newVal = String(selectedDictReference.DICTID)
            if USDICTREFERENCE != newVal {
                USDICTREFERENCE = newVal
                await MUserSetting.update(info: INFO_USDICTREFERENCE, stringValue: USDICTREFERENCE)
            }
        }

        onChange($selectedDictNoteIndex) { [unowned self] n in
//            print("selectedDictNoteIndex=\(n)")
            let newVal = selectedDictNote.DICTID
            if USDICTNOTE != newVal {
                USDICTNOTE = newVal
                await MUserSetting.update(info: INFO_USDICTNOTE, intValue: USDICTNOTE)
            }
        }

        onChange($selectedDictTranslationIndex) { [unowned self] n in
//            print("selectedDictTranslationIndex=\(n)")
            let newVal = selectedDictTranslation.DICTID
            if USDICTTRANSLATION != newVal {
                USDICTTRANSLATION = newVal
                await MUserSetting.update(info: INFO_USDICTTRANSLATION, intValue: USDICTTRANSLATION)
            }
        }

        onChange($selectedTextbookIndex) { [unowned self] n in
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
            initialized = true
            if dirty {
                await MUserSetting.update(info: INFO_USTEXTBOOK, intValue: USTEXTBOOK)
            }
        }

        onChange($selectedUnitFromIndex) { [unowned self] n in
//            print("selectedUnitFromIndex=\(n)")
            await doUpdateUnitFrom(v: selectedUnitFrom)
            if toType == .unit {
                await doUpdateSingleUnit()
            } else if toType == .part || isInvalidUnitPart {
                await doUpdateUnitPartTo()
            }
        }

        onChange($selectedPartFromIndex) { [unowned self] n in
//            print("selectedPartFromIndex=\(n)")
            await doUpdatePartFrom(v: selectedPartFrom)
            if toType == .part || isInvalidUnitPart {
                await doUpdateUnitPartTo()
            }
        }

        onChange($selectedUnitToIndex) { [unowned self] n in
//            print("selectedUnitToIndex=\(n)")
            await doUpdateUnitTo(v: selectedUnitTo)
            if isInvalidUnitPart {
                await doUpdateUnitPartFrom()
            }
        }

        onChange($selectedPartToIndex) { [unowned self] n in
//            print("selectedPartToIndex=\(n)")
            await doUpdatePartTo(v: selectedPartTo)
            if isInvalidUnitPart {
                await doUpdateUnitPartFrom()
            }
        }

        $toType_.removeDuplicates()
            .sink { [unowned self] _ in
                Task {
//                    print("toType=\(toType)")
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
            } ~ subscriptions
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
        arrOnlineTextbookFilters = x.arrOnlineTextbookFilters
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

    func getData() async {
        selectedLangIndex = -1
        async let res1 = MLanguage.getData()
        async let res2 = MUSMapping.getData()
        async let res3 = MUserSetting.getData()
        async let res4 = MCode.getData()
        (arrLanguages, arrUSMappings, arrUserSettings, arrDictTypes) = await (res1, res2, res3, res4)
        INFO_USLANG = getUSInfo(name: MUSMapping.NAME_USLANG)
        selectedLangIndex = arrLanguages.firstIndex { [unowned self] in $0.ID == USLANG } ?? 0
    }

    func updateDictsReference() async {
        let newVal = selectedDictsReference.map { String($0.DICTID) }.joined(separator: ",")
        if USDICTSREFERENCE != newVal {
            USDICTSREFERENCE = newVal
            await MUserSetting.update(info: INFO_USDICTSREFERENCE, stringValue: USDICTSREFERENCE)
        }
    }

    func autoCorrectInput(text: String) -> String {
        MAutoCorrect.autoCorrect(text: text, arrAutoCorrect: arrAutoCorrect, colFunc1: \.INPUT, colFunc2: \.EXTENDED)
    }

    func toggleToType(part: Int) async {
        switch toType {
        case .unit:
            toType = .part
            await withTaskGroup(of: Void.self) {
                $0.addTask { [unowned self] in await doUpdatePartFrom(v: part) }
                $0.addTask { [unowned self] in await doUpdateUnitPartTo() }
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
                    $0.addTask { [unowned self] in await doUpdateUnitFrom(v: n - 1) }
                    $0.addTask { [unowned self] in await doUpdateUnitTo(v: n - 1) }
                }
            }
        } else if selectedPartFrom > 1 {
            await withTaskGroup(of: Void.self) {
                $0.addTask { [unowned self] in await doUpdatePartFrom(v: selectedPartFrom - 1) }
                $0.addTask { [unowned self] in await doUpdateUnitPartTo() }
            }
        } else if selectedUnitFrom > 1 {
            await withTaskGroup(of: Void.self) {
                $0.addTask { [unowned self] in await doUpdateUnitFrom(v: selectedUnitFrom - 1) }
                $0.addTask { [unowned self] in await doUpdatePartFrom(v: partCount) }
                $0.addTask { [unowned self] in await doUpdateUnitPartTo() }
            }
        }
    }

    func nextUnitPart() async {
        if toType == .unit {
            let n = selectedUnitFrom
            if n < unitCount {
                await withTaskGroup(of: Void.self) {
                    $0.addTask { [unowned self] in await doUpdateUnitFrom(v: n + 1) }
                    $0.addTask { [unowned self] in await doUpdateUnitTo(v: n + 1) }
                }
            }
        } else if selectedPartFrom < partCount {
            await withTaskGroup(of: Void.self) {
                $0.addTask { [unowned self] in await doUpdatePartFrom(v: selectedPartFrom + 1) }
                $0.addTask { [unowned self] in await doUpdateUnitPartTo() }
            }
        } else if selectedUnitFrom < unitCount {
            await withTaskGroup(of: Void.self) {
                $0.addTask { [unowned self] in await doUpdateUnitFrom(v: selectedUnitFrom + 1) }
                $0.addTask { [unowned self] in await doUpdatePartFrom(v: 1) }
                $0.addTask { [unowned self] in await doUpdateUnitPartTo() }
            }
        }
    }

    private func doUpdateUnitPartFrom() async {
        await withTaskGroup(of: Void.self) {
            $0.addTask { [unowned self] in await doUpdateUnitFrom(v: USUNITTO) }
            $0.addTask { [unowned self] in await doUpdatePartFrom(v: USPARTTO) }
        }
    }

    private func doUpdateUnitPartTo() async {
        await withTaskGroup(of: Void.self) {
            $0.addTask { [unowned self] in await doUpdateUnitTo(v: USUNITFROM) }
            $0.addTask { [unowned self] in await doUpdatePartTo(v: USPARTFROM) }
        }
    }

    private func doUpdateSingleUnit() async {
        await withTaskGroup(of: Void.self) {
            $0.addTask { [unowned self] in await doUpdateUnitTo(v: USUNITFROM) }
            $0.addTask { [unowned self] in await doUpdatePartFrom(v: 1) }
            $0.addTask { [unowned self] in await doUpdatePartTo(v: partCount) }
        }
    }

    private func doUpdateUnitFrom(v: Int) async {
        guard USUNITFROM != v else {return}
        USUNITFROM = v
        selectedUnitFromIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        await MUserSetting.update(info: INFO_USUNITFROM, intValue: USUNITFROM)
    }

    private func doUpdatePartFrom(v: Int) async {
        guard USPARTFROM != v else {return}
        USPARTFROM = v
        selectedPartFromIndex = arrParts.firstIndex { $0.value == v } ?? 0
        await MUserSetting.update(info: INFO_USPARTFROM, intValue: USPARTFROM)
    }

    private func doUpdateUnitTo(v: Int) async {
        guard USUNITTO != v else {return}
        USUNITTO = v
        selectedUnitToIndex = arrUnits.firstIndex { $0.value == v } ?? 0
        await MUserSetting.update(info: INFO_USUNITTO, intValue: USUNITTO)
    }

    private func doUpdatePartTo(v: Int) async {
        guard USPARTTO != v else {return}
        USPARTTO = v
        selectedPartToIndex = arrParts.firstIndex { $0.value == v } ?? 0
        await MUserSetting.update(info: INFO_USPARTTO, intValue: USPARTTO)
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

    func clearNotes(wordCount: Int, isNoteEmpty: @escaping (Int) -> Bool, getOne: @MainActor @escaping (Int) async -> Void) async {
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

    func getBlogContent(unit: Int) async -> String {
        (await MUnitBlogPost.getDataByTextbook(selectedTextbook.ID, unit: unit))?.CONTENT ?? ""
    }
    func getBlogContent() async -> String {
        await getBlogContent(unit: selectedUnitTo)
    }
    func saveBlogContent(content: String) async {
        await MUnitBlogPost.update(selectedTextbook.ID, unit: selectedUnitTo, content: content)
    }
}
