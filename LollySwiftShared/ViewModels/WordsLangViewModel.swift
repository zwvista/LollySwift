//
//  WordsLangViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class WordsLangViewModel: NSObject {
    var settings: SettingsViewModel
    var arrWords = [MLangWord]()
    var arrWordsFiltered: [MLangWord]?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        self.settings = settings
        let m = settings.arrTextbooks[settings.selectedTextbookIndex]
        super.init()
        MLangWord.getDataByLang(m.LANGID) {[unowned self] in self.arrWords = $0; complete() }
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter { $0.WORD.contains(searchText) }
    }
    
    static func update(_ id: Int, word: String, complete: @escaping () -> Void) {
        MLangWord.update(id, word: word) {
            print($0)
            complete()
        }
    }
    
    static func create(m: MLangWordEdit, complete: @escaping (Int) -> Void) {
        MLangWord.create(m: m) {
            print($0)
            complete($0.toInt()!)
        }
    }
    
    static func delete(_ id: Int, complete: @escaping () -> Void) {
        MLangWord.delete(id) {
            print($0)
            complete()
        }
    }

}
