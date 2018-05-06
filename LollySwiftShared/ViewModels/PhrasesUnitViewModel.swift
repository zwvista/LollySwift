//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesUnitViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var arrPhrasesFiltered: [MUnitPhrase]?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        self.vmSettings = settings
        super.init()
        MUnitPhrase.getDataByTextbook(vmSettings.USTEXTBOOKID, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).subscribe(onNext: { [unowned self] in self.arrPhrases = $0; complete() })
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter { item in
            (scope == "Phrase" ? item.PHRASE : item.TRANSLATION!).contains(searchText)
        }
    }
    
    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        return MUnitPhrase.update(id, seqnum: seqnum).map { print($0) }
    }
    
    static func update(item: MUnitPhrase) -> Observable<()> {
        return MUnitPhrase.update(item: item).map { print($0) }
    }
    
    static func create(item: MUnitPhrase) -> Observable<Int> {
        return MUnitPhrase.create(item: item).map { print($0); return $0.toInt()! }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MUnitPhrase.delete(id).map { print($0) }
    }
    
    func reindex(complete: @escaping (Int) -> Void) {
        for i in 1...arrPhrases.count {
            let item = arrPhrases[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            PhrasesUnitViewModel.update(item.ID, seqnum: item.SEQNUM).subscribe(onNext: { complete(i - 1) })
        }
    }

    func newUnitPhrase() -> MUnitPhrase {
        let item = MUnitPhrase()
        item.TEXTBOOKID = vmSettings.USTEXTBOOKID
        let maxElem = arrPhrases.max{ ($0.UNIT, $0.PART, $0.SEQNUM) < ($1.UNIT, $1.PART, $1.SEQNUM) }
        item.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
        item.PART = maxElem?.PART ?? vmSettings.USPARTTO
        item.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
        return item
    }

}
