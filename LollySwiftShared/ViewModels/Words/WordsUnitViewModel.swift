//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding
import Then

class WordsUnitViewModel: WordsBaseViewModel {
    let inTextbook: Bool
    let arrWordsAll_ = BehaviorRelay(value: [MUnitWord]())
    var arrWordsAll: [MUnitWord] { get { arrWordsAll_.value } set { arrWordsAll_.accept(newValue) } }
    let arrWords_ = BehaviorRelay(value: [MUnitWord]())
    var arrWords: [MUnitWord] { get { arrWords_.value } set { arrWords_.accept(newValue) } }
    var hasFilter: Bool { !(textFilter.isEmpty && textbookFilter == 0) }

    init(settings: SettingsViewModel, inTextbook: Bool, complete: @escaping () -> Void) {
        self.inTextbook = inTextbook
        super.init(settings: settings)

        Observable.combineLatest(arrWordsAll_, indexTextbookFilter_, textFilter_, scopeFilter_).subscribe { [unowned self] _ in
            arrWords = arrWordsAll
            if !textFilter.isEmpty {
                arrWords = arrWords.filter { (scopeFilter == "Word" ? $0.WORD : $0.NOTE).lowercased().contains(textFilter.lowercased()) }
            }
            if textbookFilter != 0 {
                arrWords = arrWords.filter { $0.TEXTBOOKID == textbookFilter }
            }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        (inTextbook ? MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) : MUnitWord.getDataByLang(vmSettings.selectedTextbook.LANGID, arrTextbooks: vmSettings.arrTextbooks))
        .map { [unowned self] in
            arrWordsAll = $0
        }
    }

    static func update(_ id: Int, seqnum: Int) -> Single<()> {
        MUnitWord.update(id, seqnum: seqnum)
    }

    static func update(_ wordid: Int, note: String) -> Single<()> {
        MLangWord.update(wordid, note: note)
    }

    func update(item: MUnitWord) -> Single<()> {
        MUnitWord.update(item: item).flatMap { [unowned self] result in
            MUnitWord.getDataById(item.ID, arrTextbooks: vmSettings.arrTextbooks).map { ($0, result) }
        }.flatMap { [unowned self] (o, result) in
            if let o = o {
                let b = result == "2" || result == "4"
                copyProperties(from: o, to: item)
                return b || item.NOTE.isEmpty ? getNote(item: item) : Single.just(())
            } else {
                return Single.just(())
            }
        }
    }

    func create(item: MUnitWord) -> Single<()> {
        MUnitWord.create(item: item).flatMap { [unowned self] in
            MUnitWord.getDataById($0, arrTextbooks: vmSettings.arrTextbooks)
        }.flatMap { [unowned self] o in
            if let o = o {
                var arr = arrWordsAll
                arr.append(o)
                arrWordsAll = arr
                copyProperties(from: o, to: item)
                return item.NOTE.isEmpty ? getNote(item: item) : Single.just(())
            } else {
                return Single.just(())
            }
        }
    }

    static func delete(item: MUnitWord) -> Single<()> {
        MUnitWord.delete(item: item)
    }

    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrWordsAll.count {
            let item = arrWordsAll[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            WordsUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe { _ in
                complete(i - 1)
            } ~ rx.disposeBag
        }
    }

    func newUnitWord() -> MUnitWord {
        MUnitWord().then {
            $0.LANGID = vmSettings.selectedLang.ID
            $0.TEXTBOOKID = vmSettings.USTEXTBOOK
            let maxElem = arrWordsAll.max { ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
            $0.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
            $0.PART = maxElem?.PART ?? vmSettings.USPARTTO
            $0.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            $0.textbook = vmSettings.selectedTextbook
        }
    }

    func getNote(index: Int) -> Single<()> {
        getNote(item: arrWordsAll[index])
    }

    func getNote(item: MUnitWord) -> Single<()> {
        vmSettings.getNote(word: item.WORD).flatMap { note in
            item.NOTE = note
            return WordsUnitViewModel.update(item.WORDID, note: note)
        }
    }

    func getNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void, allComplete: @escaping () -> Void) {
        vmSettings.getNotes(wordCount: arrWordsAll.count, isNoteEmpty: { [unowned self] in
            !ifEmpty || (arrWordsAll[$0].NOTE).isEmpty
        }, getOne: { [unowned self] i in
            getNote(index: i).subscribe { _ in
                oneComplete(i)
            } ~ rx.disposeBag
        }, allComplete: allComplete) ~ rx.disposeBag
    }

    func clearNote(index: Int) -> Single<()> {
        let item = arrWordsAll[index]
        item.NOTE = SettingsViewModel.zeroNote
        return WordsUnitViewModel.update(item.WORDID, note: item.NOTE)
    }

    func clearNotes(ifEmpty: Bool, oneComplete: @escaping (Int) -> Void) -> Single<()> {
        vmSettings.clearNotes(wordCount: arrWordsAll.count, isNoteEmpty: { [unowned self] in
            !ifEmpty || arrWordsAll[$0].NOTE.isEmpty
        }, getOne: { [unowned self] i in
            clearNote(index: i).do(onSuccess: { oneComplete(i) })
        })
    }
}
