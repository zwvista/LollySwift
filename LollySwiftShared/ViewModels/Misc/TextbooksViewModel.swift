//
//  TextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class TextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrTextbooks = [MTextbook]()
    
    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        MTextbook.getDataByLang(settings.selectedLang.ID).subscribe(onNext: {
            self.arrTextbooks = $0
            complete()
        }) ~ rx.disposeBag
    }
    
    static func update(item: MTextbook) -> Observable<()> {
        MTextbook.update(item: item)
    }
    
    static func create(item: MTextbook) -> Observable<Int> {
        MTextbook.create(item: item)
    }

    func newTextbook() -> MTextbook {
        let item = MTextbook()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }
}
