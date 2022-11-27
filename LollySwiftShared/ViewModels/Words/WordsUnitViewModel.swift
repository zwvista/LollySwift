//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class WordsUnitViewModel: WordsBaseViewModel {
    let inTextbook: Bool
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?

    init(settings: SettingsViewModel, inTextbook: Bool, needCopy: Bool, complete: @escaping () -> ()) {
        self.inTextbook = inTextbook
        super.init(settings: settings, needCopy: needCopy)
        Task {
            await reload()
            complete()
        }
    }
    
    func reload() async {
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
    
    static func update(_ id: Int, seqnum: Int) -> Single<()> {
        MUnitWord.update(id, seqnum: seqnum)
    }
    
    static func update(_ wordid: Int, note: String) -> Single<()> {
        MLangWord.update(wordid, note: note)
    }

    func update(item: MUnitWord) -> Single<()> {
        MUnitWord.update(item: item).flatMap { result in
            MUnitWord.getDataById(item.ID, arrTextbooks: self.vmSettings.arrTextbooks).map { ($0, result) }
        }.flatMap { (o, result) in
            if let o = o {
                let b = result == "2" || result == "4"
                copyProperties(from: o, to: item)
                return b || item.NOTE.isEmpty ? self.getNote(item: item) : Single.just(())
            } else {
                return Single.just(())
            }
        }
    }
    
    func create(item: MUnitWord) -> Single<()> {
        MUnitWord.create(item: item).flatMap {
            MUnitWord.getDataById($0, arrTextbooks: self.vmSettings.arrTextbooks)
        }.flatMap { o in
            if let o = o {
                self.arrWords.append(o)
                copyProperties(from: o, to: item)
                return item.NOTE.isEmpty ? self.getNote(item: item) : Single.just(())
            } else {
                return Single.just(())
            }
        }
    }
    
    static func delete(item: MUnitWord) -> Single<()> {
        MUnitWord.delete(item: item)
    }

    func reindex(complete: @escaping (Int) -> ()) {
        for i in 1...arrWords.count {
            let item = arrWords[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            WordsUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe(onSuccess: {
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
    
    func getNote(index: Int) -> Single<()> {
        getNote(item: arrWords[index])
    }
    
    func getNote(item: MUnitWord) -> Single<()> {
        vmSettings.getNote(word: item.WORD).flatMap { note in
            item.NOTE = note
            return WordsUnitViewModel.update(item.WORDID, note: note)
        }
    }
    
    func getNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void, allComplete: @escaping () -> Void) {
        vmSettings.getNotes(wordCount: arrWords.count, isNoteEmpty: {
            !ifEmpty || (self.arrWords[$0].NOTE).isEmpty
        }, getOne: { i in
            self.getNote(index: i).subscribe(onSuccess: {
                oneComplete(i)
            }) ~ self.rx.disposeBag
        }, allComplete: allComplete) ~ self.rx.disposeBag
    }

    func clearNote(index: Int) -> Single<()> {
        let item = arrWords[index]
        item.NOTE = SettingsViewModel.zeroNote
        return WordsUnitViewModel.update(item.WORDID, note: item.NOTE)
    }
    
    func clearNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void) -> Single<()> {
        vmSettings.clearNotes(wordCount: arrWords.count, isNoteEmpty: {
            !ifEmpty || self.arrWords[$0].NOTE.isEmpty
        }, getOne: { i in
            self.clearNote(index: i).do(onSuccess: { oneComplete(i) })
        })
    }
}
