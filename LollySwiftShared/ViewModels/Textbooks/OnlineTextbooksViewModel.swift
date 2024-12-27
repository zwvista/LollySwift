//
//  OnlineTextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import Combine

@MainActor
class OnlineTextbooksViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var arrOnlineTextbooks = [MOnlineTextbook]()
    @Published var arrOnlineTextbooksFiltered = [MOnlineTextbook]()
    var selectedOnlineTextbookItem: MOnlineTextbook?
    @Published var indexOnlineTextbookFilter = 0
    @Published var stringOnlineTextbookFilter = ""
    var onlineTextbookFilter: Int {
        indexOnlineTextbookFilter == -1 ? 0 : vmSettings.arrOnlineTextbookFilters[indexOnlineTextbookFilter].value
    }

    var subscriptions = Set<AnyCancellable>()

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()

        stringOnlineTextbookFilter = vmSettings.arrOnlineTextbookFilters[0].label
        $stringOnlineTextbookFilter.sink { [unowned self] s in
            indexOnlineTextbookFilter = vmSettings.arrOnlineTextbookFilters.firstIndex { $0.label == s }!
        } ~ subscriptions
        $arrOnlineTextbooks.didSet.combineLatest($indexOnlineTextbookFilter.didSet).sink { [unowned self] _ in
            arrOnlineTextbooksFiltered = onlineTextbookFilter == 0 ? arrOnlineTextbooks : arrOnlineTextbooks.filter { $0.TEXTBOOKID == onlineTextbookFilter }
        } ~ subscriptions

        Task {
            await reload()
            complete()
        }
    }

    func reload() async {
        arrOnlineTextbooks = await MOnlineTextbook.getDataByLang(vmSettings.selectedLang.ID)
    }
}
