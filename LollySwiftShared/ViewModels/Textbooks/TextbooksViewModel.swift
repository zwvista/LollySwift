//
//  TextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class TextbooksViewModel: NSObject, ObservableObject {

    var arrTextbooks = [MTextbook]()

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

    func reload() async {
        arrTextbooks = await MTextbook.getDataByLang(vmSettings.selectedLang.ID, arrUserSettings: vmSettings.arrUserSettings)
    }
}
