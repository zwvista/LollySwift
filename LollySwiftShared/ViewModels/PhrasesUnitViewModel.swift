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
        let langphraseid = item.LANGPHRASEID
        return MUnitPhrase.getDataByLangPhrase(langphraseid).flatMap { arr -> Observable<Int> in
            if arr.isEmpty {
                return Observable.empty()
            } else {
                return MLangPhrase.getDataByLangPhrase(langid: item.LANGID, phrase: item.PHRASE).flatMap { arr2 -> Observable<Int> in
                    let item2 = MLangPhrase(item: item)
                    func f() -> Observable<Int> {
                        let item3 = arr2[0]
                        let id = item3.ID
                        let b = item2.combineTranslation(item3.TRANSLATION)
                        item.TRANSLATION = item2.TRANSLATION
                        return b ? MLangPhrase.update(id, translation: item2.TRANSLATION!).map { _ in id } : Observable.just(id)
                    }
                    if arr.count == 1 {
                        if !arr2.isEmpty {
                            return MLangPhrase.delete(langphraseid).flatMap { _ in f() }
                        } else {
                            return MLangPhrase.update(item: item2).map { _ in langphraseid }
                        }
                    } else {
                        if !arr2.isEmpty {
                            return f()
                        } else {
                            return MLangPhrase.create(item: item2)
                        }
                    }
                }
            }
        }.map {
            item.LANGPHRASEID = $0
            return MUnitPhrase.update(item: item)
        }.map { print($0) }
    }
    
    static func create(item: MUnitPhrase) -> Observable<Int> {
        return MLangPhrase.getDataByLangPhrase(langid: item.LANGID, phrase: item.PHRASE).flatMap { arr -> Observable<Int> in
            if (!arr.isEmpty) {
                let item2 = arr[0]
                let id = item2.ID
                let b = item2.combineTranslation(item.TRANSLATION)
                item.TRANSLATION = item2.TRANSLATION
                return b ? MLangPhrase.update(id, translation: item2.TRANSLATION!).map { _ in id } : Observable.just(id)
            } else {
                let item2 = MLangPhrase(item: item)
                return MLangPhrase.create(item: item2)
            }
        }.flatMap { id -> Observable<Int> in
            item.LANGPHRASEID = id
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
