//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import Then

class PhrasesUnitViewModel: PhrasesBaseViewModel {
    let inTextbook: Bool
    @Published var arrPhrases = [MUnitPhrase]()
    @Published var arrPhrasesFiltered: [MUnitPhrase]?

    public init(settings: SettingsViewModel, inTextbook: Bool, needCopy: Bool, complete: @escaping () -> Void) {
        self.inTextbook = inTextbook
        super.init(settings: settings, needCopy: needCopy)
        Task {
            await reload()
            complete()
        }
    }
    
    func reload() async {
        arrPhrases = inTextbook ? await MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : await MUnitPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks)
        arrPhrasesFiltered = nil
    }

    func applyFilters() {
        if textFilter.isEmpty && textbookFilter == 0 {
            arrPhrasesFiltered = nil
        } else {
            arrPhrasesFiltered = arrPhrases
            if !textFilter.isEmpty {
                arrPhrasesFiltered = arrPhrasesFiltered!.filter { (scopeFilter == "Phrase" ? $0.PHRASE : $0.TRANSLATION).lowercased().contains(textFilter.lowercased()) }
            }
            if textbookFilter != 0 {
                arrPhrasesFiltered = arrPhrasesFiltered!.filter { $0.TEXTBOOKID == textbookFilter }
            }
        }
    }
    
    static func update(_ id: Int, seqnum: Int) async {
        await MUnitPhrase.update(id, seqnum: seqnum)
    }
    
    func update(item: MUnitPhrase) async {
        await MUnitPhrase.update(item: item)
        if let o = await MUnitPhrase.getDataById(item.ID, arrTextbooks: vmSettings.arrTextbooks) {
            copyProperties(from: o, to: item)
        }
    }
    
    func create(item: MUnitPhrase) async {
        let id = await MUnitPhrase.create(item: item)
        if let o = await MUnitPhrase.getDataById(id, arrTextbooks: vmSettings.arrTextbooks) {
            self.arrPhrases.append(o)
            copyProperties(from: o, to: item)
        }
    }
    
    static func delete(item: MUnitPhrase) async {
        await MUnitPhrase.delete(item: item)
    }

    func reindex(complete: @escaping (Int) -> Void) async {
        for i in 1...arrPhrases.count {
            let item = arrPhrases[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            await PhrasesUnitViewModel.update(item.ID, seqnum: item.SEQNUM)
            complete(i - 1)
        }
    }

    func newUnitPhrase() -> MUnitPhrase {
        MUnitPhrase().then {
            $0.LANGID = vmSettings.selectedLang.ID
            $0.TEXTBOOKID = vmSettings.USTEXTBOOK
            let maxElem = arrPhrases.max{ ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
            $0.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
            $0.PART = maxElem?.PART ?? vmSettings.USPARTTO
            $0.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            $0.textbook = vmSettings.selectedTextbook
        }
    }
}
