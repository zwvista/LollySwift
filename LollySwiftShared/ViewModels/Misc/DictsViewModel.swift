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
    
    static func update(item: MDictionary) -> Observable<()> {
        MDictionary.update(item: item)
    }

    static func create(item: MDictionary) -> Observable<Int> {
        MDictionary.create(item: item)
    }

    func newDict() -> MDictionary {
        let item = MDictionary()
        item.LANGIDFROM = vmSettings.selectedLang.ID
        return item
    }
}
