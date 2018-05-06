//
//  PhrasesLangViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesLangViewModel: NSObject {
    var settings: SettingsViewModel
    var arrPhrases = [MLangPhrase]()
    var arrPhrasesFiltered: [MLangPhrase]?
    
    let disposeBag = DisposeBag()
    
    public init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        self.settings = settings
        let item = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MLangPhrase.getDataByLang(item.LANGID).subscribe(onNext: {
            self.arrPhrases = $0
            complete()
        }).disposed(by: disposeBag)
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (item) -> Bool in
            return (scope == "Phrase" ? item.PHRASE : item.TRANSLATION!).contains(searchText)
        })
    }
    
    static func update(_ id: Int, item: MLangPhrase) -> Observable<()> {
        return MLangPhrase.update(id, item: item).map { print($0) }
    }
    
    static func create(item: MLangPhrase) -> Observable<Int> {
        return MLangPhrase.create(item: item).map { print($0); return $0.toInt()! }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MLangPhrase.delete(id).map { print($0) }
    }

}
