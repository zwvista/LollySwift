//
//  PhrasesUnitViewModel.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class PhrasesUnitViewModel: NSObject {
    var settings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var arrPhrasesFiltered: [MUnitPhrase]?
    
    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        self.settings = settings
        super.init()
        MUnitPhrase.getDataByTextbook(settings.USTEXTBOOKID, unitPartFrom: settings.USUNITPARTFROM, unitPartTo: settings.USUNITPARTTO) { [unowned self] in self.arrPhrases = $0; complete() }
    }
    
    func filterPhrasesForSearchText(_ searchText: String, scope: String) {
        arrPhrasesFiltered = arrPhrases.filter { m in
            (scope == "Phrase" ? m.PHRASE! : m.TRANSLATION!).contains(searchText)
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

}
