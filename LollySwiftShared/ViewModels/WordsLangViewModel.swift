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
    var settings: SettingsViewModel
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        self.settings = settings
        let item = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MLangWord.getDataByLang(item.LANGID).subscribe(onNext:  {[unowned self] in self.arrWords = $0; complete() })
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter { $0.WORD.contains(searchText) }
    }
    
    static func update(_ id: Int, word: String) -> Observable<()> {
        return MLangWord.update(id, word: word).map { print($0) }
    }
    
    static func create(item: MLangWord) -> Observable<Int> {
        return MLangWord.create(item: item).map { print($0); return $0.toInt()! }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MLangWord.delete(id).map { print($0) }
    }

}
