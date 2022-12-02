//
//  TextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import Then

class TextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrTextbooks = [MTextbook]()

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        Task {
            arrTextbooks = await MTextbook.getDataByLang(settings.selectedLang.ID, arrUserSettings: settings.arrUserSettings)
            complete()
        }
    }

    static func update(item: MTextbook) async {
        await MTextbook.update(item: item)
    }

    static func create(item: MTextbook) async {
        _ = await MTextbook.create(item: item)
    }

    func newTextbook() -> MTextbook {
        MTextbook().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
