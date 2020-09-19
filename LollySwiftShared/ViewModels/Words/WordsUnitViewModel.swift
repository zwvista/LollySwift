//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx

class WordsUnitViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var vmNote: NoteViewModel!
    var mDictNote: MDictionary { vmNote.mDictNote }
    let inTextbook: Bool
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?
    var arrPhrases = [MLangPhrase]()

    init(settings: SettingsViewModel, inTextbook: Bool, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.inTextbook = inTextbook
        vmNote = NoteViewModel(settings: settings)
        super.init()
        reload().subscribe(onNext: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Observable<()> {
        (inTextbook ? MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : MUnitWord.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks))
        .map {
            self.arrWords = $0
            self.arrWordsFiltered = nil
        }
    }
    
    func applyFilters(textFilter: String, scope: String, textbookFilter: Int) {
        if textFilter.isEmpty && textbookFilter == 0 {
            arrWordsFiltered = nil
        } else {
            arrWordsFiltered = arrWords
            if !textFilter.isEmpty {
                arrWordsFiltered = arrWordsFiltered!.filter { (scope == "Word" ? $0.WORD : $0.NOTE ?? "").lowercased().contains(textFilter.lowercased()) }
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

    func update(item: MUnitWord) -> Observable<MUnitWord?> {
        MUnitWord.update(item: item).flatMap {
            MUnitWord.getDataById(item.ID, arrTextbooks: self.vmSettings.arrTextbooks)
        }
    }
    
    func create(item: MUnitWord) -> Observable<MUnitWord?> {
        MUnitWord.create(item: item).flatMap {
            MUnitWord.getDataById($0, arrTextbooks: self.vmSettings.arrTextbooks)
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
        let item = MUnitWord()
        item.LANGID = vmSettings.selectedLang.ID
        item.TEXTBOOKID = vmSettings.USTEXTBOOK
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
            self.getNote(index: i).subscribe(onNext: {
                oneComplete(i)
            }) ~ self.rx.disposeBag
        }, allComplete: allComplete)
    }

    func clearNote(index: Int) -> Observable<()> {
        let item = arrWords[index]
        item.NOTE = NoteViewModel.zeroNote
        return WordsUnitViewModel.update(item.WORDID, note: item.NOTE!)
    }
    
    func clearNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void) -> Observable<()> {
        vmNote.clearNotes(wordCount: arrWords.count, isNoteEmpty: {
            !ifEmpty || (self.arrWords[$0].NOTE ?? "").isEmpty
        }, getOne: { i in
            self.clearNote(index: i).do(onNext: { oneComplete(i) })
        })
    }
    
    func searchPhrases(wordid: Int) -> Observable<()> {
        MWordPhrase.getPhrasesByWordId(wordid).map {
            self.arrPhrases = $0
        }
    }
}
