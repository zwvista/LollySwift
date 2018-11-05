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
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?
    
    let disposeBag = DisposeBag()

    public init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        self.vmSettings = settings
        let item = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MLangWord.getDataByLang(item.LANGID).subscribe(onNext: {
            self.arrWords = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter { $0.WORD.contains(searchText) }
    }
    
    static func update(_ id: Int, word: String) -> Observable<()> {
        return MLangWord.update(id, word: word).map { print($0) }
    }
    
    static func update(item: MLangWord) -> Observable<()> {
        return MLangWord.update(item: item).map { print($0) }
    }

    static func create(item: MLangWord) -> Observable<Int> {
        return MLangWord.create(item: item).map { print($0); return $0.toInt()! }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MLangWord.delete(id).map { print($0) }
    }
    
    func newLangWord() -> MLangWord {
        let item = MLangWord()
        item.LANGID = vmSettings.selectedLang.ID
        item.LEVEL = 0
        return item
    }

}
