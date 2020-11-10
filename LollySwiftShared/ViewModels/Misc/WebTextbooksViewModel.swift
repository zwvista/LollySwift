//
//  WebTextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WebTextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWebTextbooks = [MWebTextbook]()
    
    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        MWebTextbook.getDataByLang(settings.selectedLang.ID).subscribe(onNext: {
            self.arrWebTextbooks = $0
            complete()
        }) ~ rx.disposeBag
    }
}
