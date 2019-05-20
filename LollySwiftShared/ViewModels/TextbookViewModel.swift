//
//  TextbookViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class TextbookViewModel: NSObject {
    var vmSettings: SettingsViewModel
    let disposeBag: DisposeBag!
    var arrTextbooks = [MTextbook]()
    
    init(settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        vmSettings = settings
        self.disposeBag = disposeBag
        super.init()
        MTextbook.getDataByLang(settings.selectedLang.ID).subscribe(onNext: {
            self.arrTextbooks = $0
            complete()
        }).disposed(by: disposeBag)
    }
}
