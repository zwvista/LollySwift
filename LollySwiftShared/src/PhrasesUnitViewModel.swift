//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class PhrasesUnitViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var arrPhrasesFiltered: [MUnitPhrase]?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        self.vmSettings = settings
        super.init()
        MUnitPhrase.getDataByTextbook(vmSettings.USTEXTBOOKID, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO) { [unowned self] in self.arrPhrases = $0; complete() }
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter { m in
            (scope == "Phrase" ? m.PHRASE : m.TRANSLATION!).contains(searchText)
        }
    }
    
    static func update(_ id: Int, seqnum: Int, complete: @escaping () -> Void) {
        MUnitPhrase.update(id, seqnum: seqnum) {
            print($0)
            complete()
        }
    }
    
    static func update(_ id: Int, m: MUnitPhraseEdit, complete: @escaping () -> Void) {
        MUnitPhrase.update(id, m: m) {
            print($0)
            complete()
        }
    }
    
    static func create(m: MUnitPhraseEdit, complete: @escaping (Int) -> Void) {
        MUnitPhrase.create(m: m) {
            print($0)
            complete($0.toInt()!)
        }
    }
    
    static func delete(_ id: Int, complete: @escaping () -> Void) {
        MUnitPhrase.delete(id) {
            print($0)
            complete()
        }
    }
    
    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrPhrases.count {
            let m = arrPhrases[i - 1]
            guard m.SEQNUM != i else {continue}
            m.SEQNUM = i
            PhrasesUnitViewModel.update(m.ID, seqnum: m.SEQNUM) {
                complete(i - 1)
            }
        }
    }

    func newUnitPhrase() -> MUnitPhrase {
        let o = MUnitPhrase()
        o.TEXTBOOKID = vmSettings.USTEXTBOOKID
        let maxElem = arrPhrases.max{ (o1, o2) in (o1.UNITPART, o1.SEQNUM) < (o2.UNITPART, o2.SEQNUM) }
        o.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
        o.PART = maxElem?.PART ?? vmSettings.USPARTTO
        o.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
        return o
    }

}
