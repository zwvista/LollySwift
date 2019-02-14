//
//  WordsTextbookViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsTextbookViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWords = [MTextbookWord]()
    var arrWordsFiltered: [MTextbookWord]?

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        self.vmSettings = settings
        let item = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MTextbookWord.getDataByLang(item.LANGID).subscribe(onNext: {
            self.arrWords = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter({ (item) -> Bool in
            return item.WORD.contains(searchText)
        })
    }

}
