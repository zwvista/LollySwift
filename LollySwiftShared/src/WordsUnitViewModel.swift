//
//  WordsUnitViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class WordsUnitViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWords = [MUnitWord]()
    var arrWordsFiltered: [MUnitWord]?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        self.vmSettings = settings
        super.init()
        MUnitWord.getDataByTextbook(settings.USTEXTBOOKID, unitPartFrom: settings.USUNITPARTFROM, unitPartTo: settings.USUNITPARTTO) { [unowned self] in self.arrWords = $0; complete() }
    }
    
    func filterWordsForSearchText(_ searchText: String, scope: String) {
        arrWordsFiltered = arrWords.filter { $0.WORD.contains(searchText) }
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

    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrWords.count {
            let m = arrWords[i - 1]
            guard m.SEQNUM != i else {continue}
            m.SEQNUM = i
            WordsUnitViewModel.update(m.ID, seqnum: m.SEQNUM) {
                complete(i - 1)
            }
        }
    }
    
    func newUnitWord() -> MUnitWord {
        let o = MUnitWord()
        o.TEXTBOOKID = vmSettings.USTEXTBOOKID
        let maxElem = arrWords.max{ (o1, o2) in (o1.UNITPART, o1.SEQNUM) < (o2.UNITPART, o2.SEQNUM) }
        o.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
        o.PART = maxElem?.PART ?? vmSettings.USPARTTO
        o.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
        return o
    }
}
