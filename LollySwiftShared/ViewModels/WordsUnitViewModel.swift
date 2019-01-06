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
    // var vmNote: NoteViewModel!
    let disposeBag: DisposeBag!

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        self.vmSettings = settings
        self.disposeBag = disposeBag
        // vmNote = NoteViewModel(settings: settings)
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

    func getNote(index: Int) -> Observable<()> {
        guard let mDictNote = mDictNote else {return Observable.empty() }
        let item = arrWords[index]
        let url = mDictNote.urlString(word: item.WORD, arrAutoCorrect: vmSettings.arrAutoCorrect)
        return RestApi.getHtml(url: url).concatMap { (html) -> Observable<()> in
            print(html)
            item.NOTE = HtmlApi.extractText(from: html, transform: mDictNote.TRANSFORM!, template: "") { text,_ in return text }
            return WordsUnitViewModel.update(item.ID, note: item.NOTE!)
        }
    }
    
    func getNotes(ifEmpty: Bool, rowComplete: @escaping (Int) -> Void, allComplete: @escaping () -> Void) {
        guard let mDictNote = mDictNote else {return}
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        var fromIndex = 0, toIndex = arrWords.count
        Observable<Int>.interval(Double(mDictNote.WAIT!) / 1000.0, scheduler: scheduler)
            .subscribe { [unowned self] in
                if ifEmpty {
                    while fromIndex < toIndex && !(self.arrWords[fromIndex].NOTE ?? "").isEmpty {
                        fromIndex += 1
                    }
                }
                if fromIndex >= toIndex {
                    allComplete()
                } else {
                    let i = fromIndex
                    self.getNote(index: i).subscribe {
                        rowComplete(i)
                    }.disposed(by: self.disposeBag)
                    fromIndex += 1
                }
            }.disposed(by: disposeBag)
    }
}
