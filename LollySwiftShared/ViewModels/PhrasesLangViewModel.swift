//
//  PhrasesLangViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class PhrasesLangViewModel: NSObject {
    var settings: SettingsViewModel
    var arrPhrases = [MLangPhrase]()
    var arrPhrasesFiltered: [MLangPhrase]?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        self.settings = settings
        let item = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MLangPhrase.getDataByLang(item.LANGID) { [unowned self] in self.arrPhrases = $0; complete() }
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter({ (item) -> Bool in
            return (scope == "Phrase" ? item.PHRASE : item.TRANSLATION!).contains(searchText)
        })
    }
    
    static func update(_ id: Int, item: MLangPhraseEdit, complete: @escaping () -> Void) {
        MLangPhrase.update(id, item: item) {
            print($0)
            complete()
        }
    }
    
    static func create(item: MLangPhraseEdit, complete: @escaping (Int) -> Void) {
        MLangPhrase.create(item: item) {
            print($0)
            complete($0.toInt()!)
        }
    }
    
    static func delete(_ id: Int, complete: @escaping () -> Void) {
        MLangPhrase.delete(id) {
            print($0)
            complete()
        }
    }

}
