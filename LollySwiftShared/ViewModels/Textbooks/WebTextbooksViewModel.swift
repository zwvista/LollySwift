//
//  WebTextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import Combine

@MainActor
class WebTextbooksViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var arrWebTextbooks = [MWebTextbook]()
    @Published var arrWebTextbooksFiltered = [MWebTextbook]()
    var selectedWebTextbookItem: MWebTextbook?
    @Published var indexWebTextbookFilter = 0
    @Published var stringWebTextbookFilter = ""
    var webTextbookFilter: Int {
        indexWebTextbookFilter == -1 ? 0 : vmSettings.arrWebTextbookFilters[indexWebTextbookFilter].value
    }

    var subscriptions = Set<AnyCancellable>()

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()

        stringWebTextbookFilter = vmSettings.arrWebTextbookFilters[0].label
        $stringWebTextbookFilter.sink { [unowned self] s in
            indexWebTextbookFilter = vmSettings.arrWebTextbookFilters.firstIndex { $0.label == s }!
        } ~ subscriptions
        $arrWebTextbooks.didSet.combineLatest($indexWebTextbookFilter.didSet).sink { [unowned self] _ in
            arrWebTextbooksFiltered = webTextbookFilter == 0 ? arrWebTextbooks : arrWebTextbooks.filter { $0.TEXTBOOKID == webTextbookFilter }
        } ~ subscriptions

        Task {
            await reload()
            complete()
        }
    }

    func reload() async {
        arrWebTextbooks = await MWebTextbook.getDataByLang(vmSettings.selectedLang.ID)
    }
}
