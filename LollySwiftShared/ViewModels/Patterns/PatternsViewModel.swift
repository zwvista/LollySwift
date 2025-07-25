//
//  PatternsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding
import Then

class PatternsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPatternsAll_ = BehaviorRelay(value: [MPattern]())
    var arrPatternsAll: [MPattern] { get { arrPatternsAll_.value } set { arrPatternsAll_.accept(newValue) } }
    var arrPatterns_ = BehaviorRelay(value: [MPattern]())
    var arrPatterns: [MPattern] { get { arrPatterns_.value } set { arrPatterns_.accept(newValue) } }
    var selectedPatternItem: MPattern?
    var selectedPattern: String { selectedPatternItem?.PATTERN ?? "" }
    var selectedPatternID: Int { selectedPatternItem?.ID ?? 0 }
    let textFilter_ = BehaviorRelay(value: "")
    var textFilter: String { get { textFilter_.value } set { textFilter_.accept(newValue) } }
    let scopeFilter_ = BehaviorRelay(value: SettingsViewModel.arrScopePatternFilters[0])
    var scopeFilter: String { get { scopeFilter_.value } set { scopeFilter_.accept(newValue) } }
    var hasFilter: Bool { !textFilter.isEmpty }

    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()

        Observable.combineLatest(arrPatternsAll_, textFilter_, scopeFilter_).subscribe { [unowned self] _ in
            arrPatterns = arrPatternsAll
            if !textFilter.isEmpty {
                arrPatterns = arrPatterns.filter { (scopeFilter == "Pattern" ? $0.PATTERN : $0.TAGS).lowercased().contains(textFilter.lowercased()) }
            }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        MPattern.getDataByLang(vmSettings.selectedLang.ID).map { [unowned self] in
            arrPatternsAll = $0
        }
    }
}
