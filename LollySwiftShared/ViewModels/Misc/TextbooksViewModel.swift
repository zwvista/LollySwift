//
//  TextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import Then

class TextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrTextbooks = [MTextbook]()
    
    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        MTextbook.getDataByLang(settings.selectedLang.ID, arrUserSettings: settings.arrUserSettings).subscribe(onSuccess: {
            self.arrTextbooks = $0
            complete()
        }) ~ rx.disposeBag
    }
    
    static func update(item: MTextbook) -> Single<()> {
        MTextbook.update(item: item)
    }
    
    static func create(item: MTextbook) -> Single<Int> {
        MTextbook.create(item: item)
    }

    func newTextbook() -> MTextbook {
        MTextbook().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
