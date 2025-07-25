//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class PhrasesUnitViewModel: PhrasesBaseViewModel {
    let inTextbook: Bool
    @Published var arrPhrasesAll = [MUnitPhrase]()
    @Published var arrPhrases = [MUnitPhrase]()
    var hasFilter: Bool { !(textFilter.isEmpty && textbookFilter == 0) }

    init(settings: SettingsViewModel, inTextbook: Bool) {
        self.inTextbook = inTextbook
        super.init(settings: settings)

        $arrPhrasesAll.didSet.combineLatest($indexTextbookFilter.didSet, $textFilter.didSet, $scopeFilter.didSet).sink { [unowned self] _ in
            arrPhrases = arrPhrasesAll
            if !textFilter.isEmpty {
                arrPhrases = arrPhrases.filter { (scopeFilter == "Phrase" ? $0.PHRASE : $0.TRANSLATION).lowercased().contains(textFilter.lowercased()) }
            }
            if textbookFilter != 0 {
                arrPhrases = arrPhrases.filter { $0.TEXTBOOKID == textbookFilter }
            }
        } ~ subscriptions
    }

    func reload() async {
        arrPhrasesAll = inTextbook ? await MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : await MUnitPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks)
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
            arrPhrasesAll.append(o)
            copyProperties(from: o, to: item)
        }
    }

    static func delete(item: MUnitPhrase) async {
        await MUnitPhrase.delete(item: item)
    }

    func reindex(complete: @escaping (Int) -> Void) async {
        for i in 1...arrPhrasesAll.count {
            let item = arrPhrasesAll[i - 1]
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
            let maxElem = arrPhrasesAll.max{ ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
            $0.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
            $0.PART = maxElem?.PART ?? vmSettings.USPARTTO
            $0.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            $0.textbook = vmSettings.selectedTextbook
        }
    }

    func generateBlogContent() -> String {
        arrPhrasesAll.map { $0.UNIT }.unique.count > 1 ? "Error: Multiple Units" :
        Array(Dictionary(grouping: arrPhrasesAll) {
            $0.PART
        }.values).sorted {
            $0[0].PART < $1[0].PART
        }.map { arr in
            let s = arr.map { "* \($0.PHRASE)：\($0.TRANSLATION)：\n"}.joined(separator: "")
            return "\(arr[0].PARTSTR)\n\(s)"
        }.joined(separator: "")
    }
}
