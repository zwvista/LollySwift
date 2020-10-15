//
//  DictsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class DictsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrDicts = [MDictionary]()
    
    init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        vmSettings = settings
        super.init()
        MDictionary.getDictsByLang(settings.selectedLang.ID).subscribe(onNext: {
            self.arrDicts = $0
            complete()
        }) ~ rx.disposeBag
    }
    
    static func updateDict(item: MDictionary) -> Observable<()> {
        MDictionaryDict.update(item: item)
    }

    static func createDict(item: MDictionary) -> Observable<Int> {
        MDictionaryDict.create(item: item)
    }
    
    static func updateSite(item: MDictionary) -> Observable<()> {
        MDictionarySite.update(item: item)
    }

    static func createSite(item: MDictionary) -> Observable<Int> {
        MDictionarySite.create(item: item)
    }

    func newDict() -> MDictionary {
        let item = MDictionary()
        item.LANGIDFROM = vmSettings.selectedLang.ID
        return item
    }
}
