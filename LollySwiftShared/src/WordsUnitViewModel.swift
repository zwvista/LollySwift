//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class WordsUnitViewModel: NSObject {
    var settings: SettingsViewModel
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        self.settings = settings
        super.init()
        MUnitWord.getDataByTextbook(settings.USTEXTBOOKID, unitPartFrom: settings.USUNITPARTFROM, unitPartTo: settings.USUNITPARTTO) { [unowned self] in self.arrWords = $0; complete() }
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter { $0.WORD!.contains(searchText) }
    }
    
    static func update(_ id: Int, seqnum: Int, complete: @escaping () -> Void) {
        MUnitWord.update(id, seqnum: seqnum) {
            print($0)
            complete()
        }
    }
    
    static func update(_ id: Int, m: MUnitWordEdit, complete: @escaping () -> Void) {
        MUnitWord.update(id, m: m) {
            print($0)
            complete()
        }
    }
    
    static func create(m: MUnitWordEdit, complete: @escaping (Int) -> Void) {
        MUnitWord.create(m: m) {
            print($0)
            complete($0.toInt()!)
        }
    }
    
    static func delete(_ id: Int, complete: @escaping () -> Void) {
        MUnitWord.delete(id) {
            print($0)
            complete()
        }
    }

}
