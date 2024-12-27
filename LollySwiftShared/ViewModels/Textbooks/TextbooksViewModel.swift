//
//  TextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class TextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrTextbooks = [MTextbook]()

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()
        MTextbook.getDataByLang(settings.selectedLang.ID, arrUserSettings: settings.arrUserSettings).subscribe { [unowned self] in
            arrTextbooks = $0
            complete()
        } ~ rx.disposeBag
    }

    static func update(item: MTextbook) -> Single<()> {
        MTextbook.update(item: item)
    }

    static func create(item: MTextbook) -> Single<()> {
        MTextbook.create(item: item).map { _ in }
    }

    func newTextbook() -> MTextbook {
        MTextbook().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
