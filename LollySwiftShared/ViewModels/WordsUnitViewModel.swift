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
    var vmSettings: SettingsViewModel
    var vmNote: NoteViewModel!
    var mDictNote: MDictNote {
        return vmNote.mDictNote
    }
    let inTextbook: Bool
    let disposeBag: DisposeBag!
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?

    init(settings: SettingsViewModel, inTextbook: Bool, disposeBag: DisposeBag, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.inTextbook = inTextbook
        self.disposeBag = disposeBag
        vmNote = NoteViewModel(settings: vmSettings, disposeBag: disposeBag)
        super.init()
        reload().subscribe { complete() }.disposed(by: disposeBag)
    }
    
    func reload() -> Observable<()> {
        return (inTextbook ? MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : MUnitWord.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks))
        .map {
            self.arrWords = $0
            self.arrWordsFiltered = nil
        }
    }
    
    func applyFilters(textFilter: String, scope: String, levelge0only: Bool, textbookFilter: Int) {
        if textFilter.isEmpty && !levelge0only && textbookFilter == 0 {
            arrWordsFiltered = nil
        } else {
            arrWordsFiltered = arrWords
            if !textFilter.isEmpty {
                arrWordsFiltered = arrWordsFiltered!.filter { (scope == "Word" ? $0.WORD : $0.NOTE ?? "").lowercased().contains(textFilter.lowercased()) }
            }
            if levelge0only {
                arrWordsFiltered = arrWordsFiltered!.filter { $0.LEVEL >= 0 }
            }
            if textbookFilter != 0 {
                arrWordsFiltered = arrWordsFiltered!.filter { $0.TEXTBOOKID == textbookFilter }
            }
        }
    }
    
    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        return MUnitWord.update(id, seqnum: seqnum)
    }
    
    static func update(_ wordid: Int, note: String) -> Observable<()> {
        return MLangWord.update(wordid, note: note)
    }

    static func update(item: MUnitWord) -> Observable<()> {
        let wordid = item.WORDID
        return MUnitWord.getDataByWordId(wordid).flatMap { arrUnit -> Observable<Int> in
            if arrUnit.isEmpty {
                // non-existing word
                return Observable.empty()
            } else {
                let itemLang = MLangWord(unititem: item)
                return MLangWord.getDataById(wordid).flatMap { arrLangOld -> Observable<Int> in
                    if !arrLangOld.isEmpty && arrLangOld[0].WORD == item.WORD {
                        // word intact
                        return MLangWord.update(wordid, note: item.NOTE ?? "").map { wordid }
                    } else {
                        // word changed
                        return MLangWord.getDataByLangWord(langid: item.LANGID, word: item.WORD).flatMap { arrLangNew -> Observable<Int> in
                            func f() -> Observable<Int> {
                                let itemLang = arrLangNew[0]
                                let wordid = itemLang.ID
                                item.NOTE = itemLang.NOTE
                                return MWordFami.getDataByUserWord(userid: CommonApi.userid, wordid: wordid).map { arrFami -> Int in
                                    if !arrFami.isEmpty {
                                        item.CORRECT = arrFami[0].CORRECT
                                        item.TOTAL = arrFami[0].TOTAL
                                    }
                                    return wordid
                                }
                            }
                            if arrUnit.count == 1 {
                                // exclusive
                                if arrLangNew.isEmpty {
                                    // new word
                                    return MLangWord.update(item: itemLang).map { wordid }
                                } else {
                                    // existing word
                                    return MLangWord.delete(wordid).flatMap { f() }
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
            return MUnitWord.update(item: item)
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
                return MWordFami.getDataByUserWord(userid: CommonApi.userid, wordid: wordid).flatMap { arrFami -> Observable<Int> in
                    if !arrFami.isEmpty {
                        item.CORRECT = arrFami[0].CORRECT
                        item.TOTAL = arrFami[0].TOTAL
                    }
                    return b ? MLangWord.update(wordid, note: item.NOTE ?? "").map { wordid } : Observable.just(wordid)
                }
            }
        }.flatMap { wordid -> Observable<Int> in
            item.WORDID = wordid
            return MUnitWord.create(item: item)
        }
    }
    
    static func delete(item: MUnitWord) -> Observable<()> {
        return MUnitWord.delete(item.ID).concat(
            MUnitWord.getDataByWordId(item.WORDID).flatMap {
                !$0.isEmpty ? Observable.empty() :
                Observable.zip(MLangWord.delete(item.WORDID), MWordFami.delete(item.FAMIID)).map{_ in}
            }
        )
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
        item.textbook = vmSettings.selectedTextbook
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
            return WordsUnitViewModel.update(item.WORDID, note: note)
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
