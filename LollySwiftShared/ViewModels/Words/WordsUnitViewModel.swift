//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class WordsUnitViewModel: WordsBaseViewModel {
    let inTextbook: Bool
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?

    init(settings: SettingsViewModel, inTextbook: Bool, needCopy: Bool, complete: @escaping () -> Void) {
        self.inTextbook = inTextbook
        super.init(settings: settings, needCopy: needCopy)
        Task {
            await reload()
            await MainActor.run {
                complete()
            }
        }
    }

    func reload() async {
        arrWords = inTextbook ? await MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : await MUnitWord.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks)
        arrWordsFiltered = nil
    }

    func applyFilters() {
        if textFilter.isEmpty && textbookFilter == 0 {
            arrWordsFiltered = nil
        } else {
            arrWordsFiltered = arrWords
            if !textFilter.isEmpty {
                arrWordsFiltered = arrWordsFiltered!.filter { (scopeFilter == "Word" ? $0.WORD : $0.NOTE).lowercased().contains(textFilter.lowercased()) }
            }
            if textbookFilter != 0 {
                arrWordsFiltered = arrWordsFiltered!.filter { $0.TEXTBOOKID == textbookFilter }
            }
        }
    }

    static func update(_ id: Int, seqnum: Int) async {
        await MUnitWord.update(id, seqnum: seqnum)
    }

    static func update(_ wordid: Int, note: String) async {
        await MLangWord.update(wordid, note: note)
    }

    func update(item: MUnitWord) async {
        let result = await MUnitWord.update(item: item)
        if let o = await MUnitWord.getDataById(item.ID, arrTextbooks: vmSettings.arrTextbooks) {
            let b = result == "2" || result == "4"
            copyProperties(from: o, to: item)
            if b || item.NOTE.isEmpty {
                await getNote(item: item)
            }
        }
    }
    
    func create(item: MUnitWord) async {
        let id = await MUnitWord.create(item: item)
        if let o = await MUnitWord.getDataById(id, arrTextbooks: vmSettings.arrTextbooks) {
            self.arrWords.append(o)
            copyProperties(from: o, to: item)
            if item.NOTE.isEmpty {
                await getNote(item: item)
            }
        }
    }

    static func delete(item: MUnitWord) async {
        await MUnitWord.delete(item: item)
    }

    func reindex(complete: @escaping (Int) -> Void) async {
        for i in 1...arrWords.count {
            let item = arrWords[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            await WordsUnitViewModel.update(item.ID, seqnum: item.SEQNUM)
            complete(i - 1)
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
    
    func getNote(index: Int) async {
        let item = arrWords[index]
        await getNote(item: item)
    }
    
    func getNote(item: MUnitWord) async {
        let note = await vmSettings.getNote(word: item.WORD)
        item.NOTE = note
        await WordsUnitViewModel.update(item.WORDID, note: note)
    }
    
    func getNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void, allComplete: @escaping () -> Void) async {
        await vmSettings.getNotes(wordCount: arrWords.count, isNoteEmpty: {
            !ifEmpty || (self.arrWords[$0].NOTE).isEmpty
        }, getOne: { i in
            await self.getNote(index: i)
            oneComplete(i)
        }, allComplete: allComplete)
    }

    func clearNote(index: Int) async {
        let item = arrWords[index]
        item.NOTE = SettingsViewModel.zeroNote
        await WordsUnitViewModel.update(item.WORDID, note: item.NOTE)
    }
    
    func clearNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void) async {
        await vmSettings.clearNotes(wordCount: arrWords.count, isNoteEmpty: {
            !ifEmpty || self.arrWords[$0].NOTE.isEmpty
        }, getOne: { i in
            await self.clearNote(index: i)
            oneComplete(i)
        })
    }
}
