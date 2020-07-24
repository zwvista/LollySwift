//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx

class PhrasesUnitViewModel: NSObject {
    @objc
    var vmSettings: SettingsViewModel
    let inTextbook: Bool
    var arrPhrases = [MUnitPhrase]()
    var arrPhrasesFiltered: [MUnitPhrase]?

    public init(settings: SettingsViewModel, inTextbook: Bool, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.inTextbook = inTextbook
        super.init()
        reload().subscribe { complete() } ~ rx.disposeBag
    }
    
    func reload() -> Observable<()> {
        (inTextbook ? MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : MUnitPhrase.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks))
        .map {
            self.arrPhrases = $0
            self.arrPhrasesFiltered = nil
        }
    }

    func applyFilters(textFilter: String, scope: String, textbookFilter: Int) {
        if textFilter.isEmpty && textbookFilter == 0 {
            arrPhrasesFiltered = nil
        } else {
            arrPhrasesFiltered = arrPhrases
            if !textFilter.isEmpty {
                arrPhrasesFiltered = arrPhrasesFiltered!.filter { (scope == "Phrase" ? $0.PHRASE : $0.TRANSLATION ?? "").lowercased().contains(textFilter.lowercased()) }
            }
            if textbookFilter != 0 {
                arrPhrasesFiltered = arrPhrasesFiltered!.filter { $0.TEXTBOOKID == textbookFilter }
            }
        }
    }
    
    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        MUnitPhrase.update(id, seqnum: seqnum)
    }
    
    static func update(item: MUnitPhrase) -> Observable<()> {
        let phraseid = item.PHRASEID
        return MUnitPhrase.getDataByPhraseId(phraseid).flatMap { arrUnit -> Observable<Int> in
            if arrUnit.isEmpty {
                // non-existing phrase
                return Observable.empty()
            } else {
                let itemLang = MLangPhrase(unititem: item)
                return MLangPhrase.getDataById(phraseid).flatMap { arrLangOld -> Observable<Int> in
                    if !arrLangOld.isEmpty && arrLangOld[0].PHRASE == item.PHRASE {
                        // phrase intact
                        return MLangPhrase.update(phraseid, translation: item.TRANSLATION ?? "").map { phraseid }
                    } else {
                        // phrase changed
                        return MLangPhrase.getDataByLangPhrase(langid: item.LANGID, phrase: item.PHRASE).flatMap { arrLangNew -> Observable<Int> in
                            func f() -> Observable<Int> {
                                let itemLang = arrLangNew[0]
                                let phraseid = itemLang.ID
                                let b = itemLang.combineTranslation(item.TRANSLATION)
                                item.TRANSLATION = itemLang.TRANSLATION
                                return b ? MLangPhrase.update(phraseid, translation: item.TRANSLATION ?? "").map { phraseid } : Observable.just(phraseid)
                            }
                            if arrUnit.count == 1 {
                                // exclusive
                                if arrLangNew.isEmpty {
                                    // new phrase
                                    return MLangPhrase.update(item: itemLang).map { phraseid }
                                } else {
                                    // existing phrase
                                    return MLangPhrase.delete(phraseid).flatMap { f() }
                                }
                            } else {
                                if arrLangNew.isEmpty {
                                    // new phrase
                                    itemLang.ID = 0
                                    return MLangPhrase.create(item: itemLang)
                                } else {
                                    // existing phrase
                                    return f()
                                }
                            }
                        }
                    }
                }
            }
        }.flatMap { phraseid -> Observable<()> in
            item.PHRASEID = phraseid
            return MUnitPhrase.update(item: item)
        }
    }
    
    static func create(item: MUnitPhrase) -> Observable<Int> {
        MLangPhrase.getDataByLangPhrase(langid: item.LANGID, phrase: item.PHRASE).flatMap { arrLang -> Observable<Int> in
            if arrLang.isEmpty {
                let itemLang = MLangPhrase(unititem: item)
                return MLangPhrase.create(item: itemLang)
            } else {
                let itemLang = arrLang[0]
                let phraseid = itemLang.ID
                let b = itemLang.combineTranslation(item.TRANSLATION)
                item.TRANSLATION = itemLang.TRANSLATION
                return b ? MLangPhrase.update(phraseid, translation: item.TRANSLATION ?? "").map { phraseid } : Observable.just(phraseid)
            }
        }.flatMap { phraseid -> Observable<Int> in
            item.PHRASEID = phraseid
            return MUnitPhrase.create(item: item)
        }
    }
    
    static func delete(item: MUnitPhrase) -> Observable<()> {
        let phraseid = item.PHRASEID
        return MUnitPhrase.delete(item.ID).concat(
            Observable.zip(MUnitPhrase.getDataByPhraseId(phraseid), MWordPhrase.getWordsByPhraseId(phraseid), MPatternPhrase.getDataByPhraseId(phraseid)).flatMap {
                !($0.0.isEmpty && $0.1.isEmpty && $0.2.isEmpty) ? Observable.empty() : MLangPhrase.delete(phraseid)
            }
        )
    }

    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrPhrases.count {
            let item = arrPhrases[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            PhrasesUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe(onNext: {
                complete(i - 1)
            }) ~ rx.disposeBag
        }
    }

    func newUnitPhrase() -> MUnitPhrase {
        let item = MUnitPhrase()
        item.LANGID = vmSettings.selectedLang.ID
        item.TEXTBOOKID = vmSettings.USTEXTBOOKID
        let maxElem = arrPhrases.max{ ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
        item.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
        item.PART = maxElem?.PART ?? vmSettings.USPARTTO
        item.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
        item.textbook = vmSettings.selectedTextbook
        return item
    }
    
    func movePhrase(at oldIndex: Int, to newIndex: Int) {
        let item = arrPhrases.remove(at: oldIndex)
        arrPhrases.insert(item, at: newIndex)
    }
}
