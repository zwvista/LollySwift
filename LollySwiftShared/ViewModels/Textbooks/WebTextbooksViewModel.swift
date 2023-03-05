//
//  WebTextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

@MainActor
class WebTextbooksViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    var arrWebTextbooks = [MWebTextbook]()
    var arrWebTextbooksFiltered: [MWebTextbook]?

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        Task {
            arrWebTextbooks = await MWebTextbook.getDataByLang(settings.selectedLang.ID)
            arrWebTextbooksFiltered = nil
            complete()
        }
    }

    func applyFilters(textbookFilter: Int) {
        arrWebTextbooksFiltered = textbookFilter == 0 ? nil : arrWebTextbooks.filter { $0.TEXTBOOKID == textbookFilter }
    }

    static func update(item: MWebTextbook) async {
        await MWebTextbook.update(item: item)
    }

    static func create(item: MWebTextbook) async {
        _ = await MWebTextbook.create(item: item)
    }

    func newWebTextbook() -> MWebTextbook {
        MWebTextbook().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
