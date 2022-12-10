//
//  DictsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

@MainActor
class DictsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrDicts = [MDictionary]()

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()
        Task {
            arrDicts = await MDictionary.getDictsByLang(settings.selectedLang.ID)
            complete()
        }
    }

    static func update(item: MDictionary) async {
        await MDictionary.update(item: item)
    }

    static func create(item: MDictionary) async -> Int {
        await MDictionary.create(item: item)
    }

    func newDict() -> MDictionary {
        let item = MDictionary()
        item.LANGIDFROM = vmSettings.selectedLang.ID
        return item
    }
}
