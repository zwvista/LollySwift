//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsUnitViewModel: NSObject {
    @objc
    var vmSettings: SettingsViewModel
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?
    var vmNote: NoteViewModel!
    var mDictNote: MDictNote? {
        return vmNote.mDictNote
    }
    let disposeBag: DisposeBag!

    init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        self.vmSettings = settings
        self.disposeBag = disposeBag
        vmNote = NoteViewModel(settings: settings, disposeBag: disposeBag)
        super.init()
        MUnitWord.getDataByTextbook(settings.USTEXTBOOKID, unitPartFrom: settings.USUNITPARTFROM, unitPartTo: settings.USUNITPARTTO).subscribe(onNext: {
            self.arrWords = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter { $0.WORD.contains(searchText) }
    }
    
    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        return MUnitWord.update(id, seqnum: seqnum).map { print($0) }
    }
    
    static func update(_ wordid: Int, note: String) -> Observable<()> {
        return MLangWord.update(wordid, note: note).map { print($0) }
    }

    static func update(item: MUnitWord) -> Observable<()> {
        let wordid = item.WORDID
        return MUnitWord.getDataByLangWord(wordid).flatMap { arrUnit -> Observable<Int> in
            if arrUnit.isEmpty {
                // non-existing word
                return Observable.empty()
            } else {
                let itemLang = MLangWord(unititem: item)
                return MLangWord.getDataById(wordid).flatMap { arrLangOld -> Observable<Int> in
                    if !arrLangOld.isEmpty && arrLangOld[0].WORD == item.WORD {
                        // word intact
                        return MLangWord.update(wordid, note: item.NOTE ?? "").map { _ in wordid }
                    } else {
                        // word changed
                        return MLangWord.getDataByLangWord(langid: item.LANGID, word: item.WORD).flatMap { arrLangNew -> Observable<Int> in
                            func f() -> Observable<Int> {
                                let itemLang = arrLangNew[0]
                                let wordid = itemLang.ID
                                let b = itemLang.combineNote(item.NOTE)
                                item.NOTE = itemLang.NOTE
                                return b ? MLangWord.update(wordid, note: item.NOTE ?? "").map { result in print(result); return wordid } : Observable.just(wordid)
                            }
                            if arrUnit.count == 1 {
                                // exclusive
                                if arrLangNew.isEmpty {
                                    // new word
                                    return MLangWord.update(item: itemLang).map { result in print(result); return wordid }
                                } else {
                                    // existing word
                                    return MLangWord.delete(wordid).flatMap { result -> Observable<Int> in print(result); return f() }
                                }
                            } else {
                                // non-exclusive
                                if arrLangNew.isEmpty {
                                    // new word
                                    itemLang.ID = 0
                                    return MLangWord.create(item: itemLang)
                                } else {
                                    // existing word
                                    return f()
                                }
                            }
                        }
                    }
                }
            }
        }.flatMap { wordid -> Observable<()> in
            item.WORDID = wordid
            return MUnitWord.update(item: item).map { print($0) }
        }
    }
    
    static func create(item: MUnitWord) -> Observable<Int> {
        return MLangWord.getDataByLangWord(langid: item.LANGID, word: item.WORD).flatMap { arrLang -> Observable<Int> in
            if arrLang.isEmpty {
                let itemLang = MLangWord(unititem: item)
                return MLangWord.create(item: itemLang)
            } else {
                let itemLang = arrLang[0]
                let wordid = itemLang.ID
                let b = itemLang.combineNote(item.NOTE)
                item.NOTE = itemLang.NOTE
                return b ? MLangWord.update(wordid, note: item.NOTE ?? "").map { result in print(result); return wordid } : Observable.just(wordid)
            }
        }.flatMap { wordid -> Observable<Int> in
            item.WORDID = wordid
            return MUnitWord.create(item: item)
        }
    }
    
    static func delete(item: MUnitWord) -> Observable<()> {
        return MUnitWord.delete(item.ID).flatMap {
            return MUnitWord.getDataByLangWord(item.WORDID)
        }.flatMap { arr -> Observable<()> in
            return !arr.isEmpty ? Observable<()>.empty() : MLangWord.delete(item.WORDID)
        }
    }

    func reindex(complete: @escaping (Int) -> ()) {
        for i in 1...arrWords.count {
            let item = arrWords[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            WordsUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe(onNext: {
                complete(i - 1)
            }).disposed(by: disposeBag)
        }
    }
    
    func newUnitWord() -> MUnitWord {
        let item = MUnitWord()
        item.LANGID = vmSettings.selectedLang.ID
        item.TEXTBOOKID = vmSettings.USTEXTBOOKID
        let maxElem = arrWords.max { ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
        item.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
        item.PART = maxElem?.PART ?? vmSettings.USPARTTO
        item.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
        item.arrUnits = vmSettings.arrUnits
        item.arrParts = vmSettings.arrParts
        return item
    }
    
    func moveWord(at oldIndex: Int, to newIndex: Int) {
        let item = arrWords.remove(at: oldIndex)
        arrWords.insert(item, at: newIndex)
    }

    func getNote(index: Int) -> Observable<()> {
        let item = arrWords[index]
        return vmNote.getNote(word: item.WORD).flatMap { note -> Observable<()> in
            item.NOTE = note
            return WordsUnitViewModel.update(item.ID, note: note)
        }
    }
    
    func getNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void, allComplete: @escaping () -> Void) {
        vmNote.getNotes(wordCount: arrWords.count, isNoteEmpty: {
            !ifEmpty || (self.arrWords[$0].NOTE ?? "").isEmpty
        }, getOne: { i in
            self.getNote(index: i).subscribe {
                oneComplete(i)
            }.disposed(by: self.disposeBag)
        }, allComplete: allComplete)
    }
}
