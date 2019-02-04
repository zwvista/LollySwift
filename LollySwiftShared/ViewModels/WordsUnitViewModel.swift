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
    
    static func update(_ langwordid: Int, note: String) -> Observable<()> {
        return MLangWord.update(langwordid, note: note).map { print($0) }
    }

    static func update(item: MUnitWord) -> Observable<()> {
        let langwordid = item.LANGWORDID
        return MUnitWord.getDataByLangWord(langwordid).flatMap { arr -> Observable<Int> in
            if arr.isEmpty {
                // non-existing word
                return Observable.empty()
            } else {
                return MLangWord.getDataByLangWord(langid: item.LANGID, word: item.WORD).flatMap { arr2 -> Observable<Int> in
                    let item2 = MLangWord(item: item)
                    func f() -> Observable<Int> {
                        let item3 = arr2[0]
                        let id = item3.ID
                        let b = item2.combineNote(item3.NOTE)
                        item.NOTE = item2.NOTE
                        return b ? MLangWord.update(id, note: item2.NOTE!).map { _ in id } : Observable.just(id)
                    }
                    if arr.count == 1 {
                        if !arr2.isEmpty {
                            // existing word
                            return MLangWord.delete(langwordid).flatMap { _ in f() }
                        } else {
                            // new word
                            return MLangWord.update(item: item2).map { _ in langwordid }
                        }
                    } else {
                        if !arr2.isEmpty {
                            // existing word
                            return f()
                        } else {
                            // new word
                            return MLangWord.create(item: item2)
                        }
                    }
                }
            }
        }.map {
            item.LANGWORDID = $0
            return MUnitWord.update(item: item)
        }.map { print($0) }
    }
    
    static func create(item: MUnitWord) -> Observable<Int> {
        return MLangWord.getDataByLangWord(langid: item.LANGID, word: item.WORD).flatMap { arr -> Observable<Int> in
            if (!arr.isEmpty) {
                let item2 = arr[0]
                let id = item2.ID
                let b = item2.combineNote(item.NOTE)
                item.NOTE = item2.NOTE
                return b ? MLangWord.update(id, note: item2.NOTE!).map { _ in id } : Observable.just(id)
            } else {
                let item2 = MLangWord(item: item)
                return MLangWord.create(item: item2)
            }
        }.flatMap { id -> Observable<Int> in
            item.LANGWORDID = id
            return MUnitWord.create(item: item)
        }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MUnitWord.delete(id).map { print($0) }
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
        return item
    }
    
    func moveWord(at oldIndex: Int, to newIndex: Int) {
        let item = arrWords.remove(at: oldIndex)
        arrWords.insert(item, at: newIndex)
    }

    func getNote(index: Int) -> Observable<()> {
        let item = arrWords[index]
        return vmNote.getNote(word: item.WORD).concatMap { note -> Observable<()> in
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
