//
//  PatternsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import Combine
import Then

@MainActor
class PatternsViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var arrPatterns = [MPattern]()
    @Published var arrPatternsFiltered = [MPattern]()
    var selectedPatternItem: MPattern?
    var selectedPattern: String { selectedPatternItem?.PATTERN ?? "" }
    var selectedPatternID: Int { selectedPatternItem?.ID ?? 0 }
    @Published var textFilter = ""
    @Published var scopeFilter = SettingsViewModel.arrScopePatternFilters[0]
    var hasFilter: Bool { !textFilter.isEmpty }
    var subscriptions = Set<AnyCancellable>()

    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()

        $arrPatterns.didSet.combineLatest($textFilter.didSet, $scopeFilter.didSet).sink { [unowned self] _ in
            arrPatternsFiltered = arrPatterns
            if !textFilter.isEmpty {
                arrPatternsFiltered = arrPatternsFiltered.filter { (scopeFilter == "Pattern" ? $0.PATTERN : $0.TAGS).lowercased().contains(textFilter.lowercased()) }
            }
        } ~ subscriptions

        Task {
            await reload()
            complete()
        }
    }

    func reload() async {
        arrPatterns = await MPattern.getDataByLang(vmSettings.selectedLang.ID)
    }
}
