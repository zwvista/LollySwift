//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesUnitViewModel: NSObject {
    @objc
    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var arrPhrasesFiltered: [MUnitPhrase]?
    let disposeBag: DisposeBag!

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        self.vmSettings = settings
        self.disposeBag = disposeBag
        super.init()
        MUnitPhrase.getDataByTextbook(vmSettings.USTEXTBOOKID, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).subscribe(onNext: {
            self.arrPhrases = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter { item in
            (scope == "Phrase" ? item.PHRASE : item.TRANSLATION!).contains(searchText)
        }
    }
    
    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        return MUnitPhrase.update(id, seqnum: seqnum).map { print($0) }
    }
    
    static func update(item: MUnitPhrase) -> Observable<()> {
        let phraseid = item.PHRASEID
        return MUnitPhrase.getDataByLangPhrase(phraseid).flatMap { arrUnit -> Observable<Int> in
            if arrUnit.isEmpty {
                // non-existing phrase
                return Observable.empty()
            } else {
                let itemLang = MLangPhrase(unititem: item)
                return MLangPhrase.getDataById(phraseid).flatMap { arrLangOld -> Observable<Int> in
                    if !arrLangOld.isEmpty && arrLangOld[0].PHRASE == item.PHRASE {
                        // phrase intact
                        return MLangPhrase.update(phraseid, translation: item.TRANSLATION ?? "").map { _ in phraseid }
                    } else {
                        // phrase changed
                        return MLangPhrase.getDataByLangPhrase(langid: item.LANGID, phrase: item.PHRASE).flatMap { arrLangNew -> Observable<Int> in
                            func f() -> Observable<Int> {
                                let itemLang = arrLangNew[0]
                                let phraseid = itemLang.ID
                                let b = itemLang.combineTranslation(item.TRANSLATION)
                                item.TRANSLATION = itemLang.TRANSLATION
                                return b ? MLangPhrase.update(phraseid, translation: item.TRANSLATION ?? "").map { result in print(result); return phraseid } : Observable.just(phraseid)
                            }
                            if arrUnit.count == 1 {
                                // exclusive
                                if arrLangNew.isEmpty {
                                    // new phrase
                                    return MLangPhrase.update(item: itemLang).map { result in print(result); return phraseid }
                                } else {
                                    // existing phrase
                                    return MLangPhrase.delete(phraseid).flatMap { result -> Observable<Int> in print(result); return f() }
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
            return MUnitPhrase.update(item: item).map { print($0) }
        }
    }
    
    static func create(item: MUnitPhrase) -> Observable<Int> {
        return MLangPhrase.getDataByLangPhrase(langid: item.LANGID, phrase: item.PHRASE).flatMap { arrLang -> Observable<Int> in
            if arrLang.isEmpty {
                let itemLang = MLangPhrase(unititem: item)
                return MLangPhrase.create(item: itemLang)
            } else {
                let itemLang = arrLang[0]
                let phraseid = itemLang.ID
                let b = itemLang.combineTranslation(item.TRANSLATION)
                item.TRANSLATION = itemLang.TRANSLATION
                return b ? MLangPhrase.update(phraseid, translation: item.TRANSLATION ?? "").map { _ in phraseid } : Observable.just(phraseid)
            }
        }.flatMap { phraseid -> Observable<Int> in
            item.PHRASEID = phraseid
            return MUnitPhrase.create(item: item)
        }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MUnitPhrase.delete(id).map { print($0) }
    }
    
    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrPhrases.count {
            let item = arrPhrases[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            PhrasesUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe(onNext: {
                complete(i - 1)
            }).disposed(by: disposeBag)
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
        return item
    }
    
    func movePhrase(at oldIndex: Int, to newIndex: Int) {
        let item = arrPhrases.remove(at: oldIndex)
        arrPhrases.insert(item, at: newIndex)
    }
}
