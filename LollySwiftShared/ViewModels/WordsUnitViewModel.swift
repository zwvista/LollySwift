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
    var mDictNote: MDictNote? {
        return vmSettings.selectedDictNote
    }
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?
    var noteFromIndex = 0, noteToIndex = 0, noteIfEmpty = true
    
    let disposeBag = DisposeBag()

    public init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        self.vmSettings = settings
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
    
    static func update(_ id: Int, note: String) -> Observable<()> {
        return MUnitWord.update(id, note: note).map { print($0) }
    }

    static func update(item: MUnitWord) -> Observable<()> {
        return MUnitWord.update(item: item).map { print($0) }
    }
    
    static func create(item: MUnitWord) -> Observable<Int> {
        return MUnitWord.create(item: item).map { print($0); return $0.toInt()! }
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
        item.TEXTBOOKID = vmSettings.USTEXTBOOKID
        let maxElem = arrWords.max{ ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
        item.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
        item.PART = maxElem?.PART ?? vmSettings.USPARTTO
        item.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
        return item
    }
    
    func moveWord(at oldIndex: Int, to newIndex: Int) {
        let item = arrWords.remove(at: oldIndex)
        arrWords.insert(item, at: newIndex)
    }

    func getNote(index: Int, complete: @escaping () -> Void) {
        guard let mDictNote = mDictNote else {return}
        let item = arrWords[index]
        let url = mDictNote.urlString(item.WORD)
        RestApi.getHtml(url: url).subscribe(onNext: { html in
//            print(html)
            item.NOTE = mDictNote.htmlNote(html)
            WordsUnitViewModel.update(item.ID, note: item.NOTE!).subscribe(onNext: {
                complete()
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    func getNotes(ifEmpty: Bool, complete: (Int) -> Void) {
        guard let mDictNote = mDictNote else {return}
        noteFromIndex = 0; noteToIndex = arrWords.count; noteIfEmpty = ifEmpty
        complete(mDictNote.WAIT!)
    }
    
    func getNextNote(rowComplete: @escaping (Int) -> Void, allComplete: @escaping () -> Void) {
        if noteIfEmpty {
            while noteFromIndex < noteToIndex && !(arrWords[noteFromIndex].NOTE ?? "").isEmpty {
                noteFromIndex += 1
            }
        }
        if noteFromIndex >= noteToIndex {
            allComplete()
        } else {
            let i = noteFromIndex
            getNote(index: i) { rowComplete(i) }
            noteFromIndex += 1
        }
    }
}
