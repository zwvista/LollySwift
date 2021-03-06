//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import Then

class WordsUnitViewModel: WordsBaseViewModel {
    let inTextbook: Bool
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?

    init(settings: SettingsViewModel, inTextbook: Bool, needCopy: Bool, complete: @escaping () -> ()) {
        self.inTextbook = inTextbook
        super.init(settings: settings, needCopy: needCopy)
        reload().subscribe(onNext: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Observable<()> {
        (inTextbook ? MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : MUnitWord.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks))
        .map {
            self.arrWords = $0
            self.arrWordsFiltered = nil
        }
    }
    
    func applyFilters() {
        if textFilter.value.isEmpty && textbookFilter == 0 {
            arrWordsFiltered = nil
        } else {
            arrWordsFiltered = arrWords
            if !textFilter.value.isEmpty {
                arrWordsFiltered = arrWordsFiltered!.filter { (scopeFilter.value == "Word" ? $0.WORD : $0.NOTE).lowercased().contains(textFilter.value.lowercased()) }
            }
            if textbookFilter != 0 {
                arrWordsFiltered = arrWordsFiltered!.filter { $0.TEXTBOOKID == textbookFilter }
            }
        }
    }
    
    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        MUnitWord.update(id, seqnum: seqnum)
    }
    
    static func update(_ wordid: Int, note: String) -> Observable<()> {
        MLangWord.update(wordid, note: note)
    }

    func update(item: MUnitWord) -> Observable<()> {
        MUnitWord.update(item: item).flatMap { result in
            MUnitWord.getDataById(item.ID, arrTextbooks: self.vmSettings.arrTextbooks).map { ($0, result) }
        }.flatMap { (o, result) -> Observable<()> in
            if let o = o {
                let b = result == "2" || result == "4"
                copyProperties(from: o, to: item)
                return b || item.NOTE.isEmpty ? self.getNote(item: item) : Observable.just(())
            } else {
                return Observable.just(())
            }
        }
    }
    
    func create(item: MUnitWord) -> Observable<()> {
        MUnitWord.create(item: item).flatMap {
            MUnitWord.getDataById($0, arrTextbooks: self.vmSettings.arrTextbooks)
        }.flatMap { o -> Observable<()> in
            if let o = o {
                self.arrWords.append(o)
                copyProperties(from: o, to: item)
                return item.NOTE.isEmpty ? self.getNote(item: item) : Observable.just(())
            } else {
                return Observable.just(())
            }
        }
    }
    
    static func delete(item: MUnitWord) -> Observable<()> {
        MUnitWord.delete(item: item)
    }

    func reindex(complete: @escaping (Int) -> ()) {
        for i in 1...arrWords.count {
            let item = arrWords[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            WordsUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe(onNext: {
                complete(i - 1)
            }) ~ rx.disposeBag
        }
    }
    
    func newUnitWord() -> MUnitWord {
        MUnitWord().then {
            $0.LANGID = vmSettings.selectedLang.ID
            $0.TEXTBOOKID = vmSettings.USTEXTBOOK
            let maxElem = arrWords.max { ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
            $0.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
            $0.PART = maxElem?.PART ?? vmSettings.USPARTTO
            $0.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            $0.textbook = vmSettings.selectedTextbook
        }
    }
    
    func getNote(index: Int) -> Observable<()> {
        getNote(item: arrWords[index])
    }
    
    func getNote(item: MUnitWord) -> Observable<()> {
        vmSettings.getNote(word: item.WORD).flatMap { note -> Observable<()> in
            item.NOTE = note
            return WordsUnitViewModel.update(item.WORDID, note: note)
        }
    }
    
    func getNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void, allComplete: @escaping () -> Void) {
        vmSettings.getNotes(wordCount: arrWords.count, isNoteEmpty: {
            !ifEmpty || (self.arrWords[$0].NOTE).isEmpty
        }, getOne: { i in
            self.getNote(index: i).subscribe(onNext: {
                oneComplete(i)
            }) ~ self.rx.disposeBag
        }, allComplete: allComplete) ~ self.rx.disposeBag
    }

    func clearNote(index: Int) -> Observable<()> {
        let item = arrWords[index]
        item.NOTE = SettingsViewModel.zeroNote
        return WordsUnitViewModel.update(item.WORDID, note: item.NOTE)
    }
    
    func clearNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void) -> Observable<()> {
        vmSettings.clearNotes(wordCount: arrWords.count, isNoteEmpty: {
            !ifEmpty || self.arrWords[$0].NOTE.isEmpty
        }, getOne: { i in
            self.clearNote(index: i).do(onNext: { oneComplete(i) })
        })
    }
}
