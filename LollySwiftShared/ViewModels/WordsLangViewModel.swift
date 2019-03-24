//
//  WordsLangViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsLangViewModel: WordsBaseViewModel {
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        super.init(settings: settings, disposeBag: disposeBag)
        let item = settings.selectedTextbook!
        MLangWord.getDataByLang(item.LANGID).subscribe(onNext: {
            self.arrWords = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter { $0.WORD.contains(searchText) }
    }
    
    static func update(item: MLangWord) -> Observable<()> {
        return MLangWord.update(item: item)
    }

    static func create(item: MLangWord) -> Observable<Int> {
        return MLangWord.create(item: item)
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MLangWord.delete(id)
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
            return MLangWord.update(item.ID, note: note).map { print($0) }
        }
    }

}
