//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class PhrasesUnitViewModel: PhrasesBaseViewModel {
    let inTextbook: Bool
    var arrPhrases = [MUnitPhrase]()
    var arrPhrasesFiltered: [MUnitPhrase]?

    public init(settings: SettingsViewModel, inTextbook: Bool, needCopy: Bool, complete: @escaping () -> Void) {
        self.inTextbook = inTextbook
        super.init(settings: settings, needCopy: needCopy)
        reload().subscribe(onSuccess: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Single<()> {
        (inTextbook ? MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : MUnitPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks))
        .map {
            self.arrPhrases = $0
            self.arrPhrasesFiltered = nil
        }
    }

    func applyFilters() {
        if textFilter.value.isEmpty && textbookFilter == 0 {
            arrPhrasesFiltered = nil
        } else {
            arrPhrasesFiltered = arrPhrases
            if !textFilter.value.isEmpty {
                arrPhrasesFiltered = arrPhrasesFiltered!.filter { (scopeFilter.value == "Phrase" ? $0.PHRASE : $0.TRANSLATION).lowercased().contains(textFilter.value.lowercased()) }
            }
            if textbookFilter != 0 {
                arrPhrasesFiltered = arrPhrasesFiltered!.filter { $0.TEXTBOOKID == textbookFilter }
            }
        }
    }
    
    static func update(_ id: Int, seqnum: Int) -> Single<()> {
        MUnitPhrase.update(id, seqnum: seqnum)
    }
    
    func update(item: MUnitPhrase) -> Single<()> {
        MUnitPhrase.update(item: item).flatMap {
            MUnitPhrase.getDataById(item.ID, arrTextbooks: self.vmSettings.arrTextbooks)
        }.map {
            if let o = $0 { copyProperties(from: o, to: item) }
        }
    }
    
    func create(item: MUnitPhrase) -> Single<()> {
        MUnitPhrase.create(item: item).flatMap {
            MUnitPhrase.getDataById($0, arrTextbooks: self.vmSettings.arrTextbooks)
        }.map {
            if let o = $0 {
                self.arrPhrases.append(o)
                copyProperties(from: o, to: item)
            }
        }
    }
    
    static func delete(item: MUnitPhrase) -> Single<()> {
        MUnitPhrase.delete(item: item)
    }

    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrPhrases.count {
            let item = arrPhrases[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            PhrasesUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe(onSuccess: {
                complete(i - 1)
            }) ~ rx.disposeBag
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
