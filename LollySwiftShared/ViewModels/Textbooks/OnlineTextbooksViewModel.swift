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
    @Published var arrOnlineTextbooksAll = [MOnlineTextbook]()
    @Published var arrOnlineTextbooks = [MOnlineTextbook]()
    var selectedOnlineTextbookItem: MOnlineTextbook?
    @Published var indexOnlineTextbookFilter = 0
    @Published var stringOnlineTextbookFilter = ""
    var onlineTextbookFilter: Int {
        indexOnlineTextbookFilter == -1 ? 0 : vmSettings.arrOnlineTextbookFilters[indexOnlineTextbookFilter].value
    }

    var subscriptions = Set<AnyCancellable>()

    init(settings: SettingsViewModel) {
        vmSettings = settings
        super.init()

        stringOnlineTextbookFilter = vmSettings.arrOnlineTextbookFilters[0].label
        $stringOnlineTextbookFilter.sink { [unowned self] s in
            indexOnlineTextbookFilter = vmSettings.arrOnlineTextbookFilters.firstIndex { $0.label == s }!
        } ~ subscriptions
        $arrOnlineTextbooksAll.didSet.combineLatest($indexOnlineTextbookFilter.didSet).sink { [unowned self] _ in
            arrOnlineTextbooks = onlineTextbookFilter == 0 ? arrOnlineTextbooksAll : arrOnlineTextbooksAll.filter { $0.TEXTBOOKID == onlineTextbookFilter }
        } ~ subscriptions
    }

    func reload() async {
        arrOnlineTextbooksAll = await MOnlineTextbook.getDataByLang(vmSettings.selectedLang.ID)
    }
}
