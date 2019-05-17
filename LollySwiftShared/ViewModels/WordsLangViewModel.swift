//
//  WordsLangViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsLangViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var vmNote: NoteViewModel!
    var mDictNote: MDictNote {
        return vmNote.mDictNote
    }
    let disposeBag: DisposeBag!
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        vmSettings = settings
        self.disposeBag = disposeBag
        vmNote = NoteViewModel(settings: settings, disposeBag: disposeBag)
        super.init()
        let item = settings.selectedTextbook!
        MLangWord.getDataByLang(item.LANGID).subscribe(onNext: {
            self.arrWords = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func applyFilters(textFilter: String, scope: String, levelge0only: Bool) {
        if textFilter.isEmpty && !levelge0only {
            arrWordsFiltered = nil
        } else {
            arrWordsFiltered = arrWords
            if !textFilter.isEmpty {
                arrWordsFiltered = arrWordsFiltered!.filter { (scope == "Word" ? $0.WORD : $0.NOTE ?? "").contains(textFilter) }
            }
            if levelge0only {
                arrWordsFiltered = arrWordsFiltered!.filter { $0.LEVEL >= 0 }
            }
        }
    }
    
    static func update(item: MLangWord) -> Observable<()> {
        return MLangWord.update(item: item)
    }

    static func create(item: MLangWord) -> Observable<Int> {
        return MLangWord.create(item: item)
    }
    
    static func delete(item: MLangWord) -> Observable<()> {
        return MLangWord.delete(item.ID).flatMap {
            return MWordFami.delete(item.FAMIID)
        }
    }
    
    func newLangWord() -> MLangWord {
        let item = MLangWord()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }

    func getNote(index: Int) -> Observable<()> {
        let item = arrWords[index]
        return vmNote.getNote(word: item.WORD).flatMap { note -> Observable<()> in
            item.NOTE = note
            return MLangWord.update(item.ID, note: note)
        }
    }

}
