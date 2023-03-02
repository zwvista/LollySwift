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
    var arrPatterns_ = BehaviorRelay(value: [MPattern]())
    var arrPatterns: [MPattern] { get { arrPatterns_.value } set { arrPatterns_.accept(newValue) } }
    var arrPatternsFiltered_ = BehaviorRelay(value: [MPattern]())
    var arrPatternsFiltered: [MPattern] { get { arrPatternsFiltered_.value } set { arrPatternsFiltered_.accept(newValue) } }
    var selectedPatternItem: MPattern?
    var selectedPattern: String { selectedPatternItem?.PATTERN ?? "" }
    var selectedPatternID: Int { selectedPatternItem?.ID ?? 0 }
    let textFilter_ = BehaviorRelay(value: "")
    var textFilter: String { get { textFilter_.value } set { textFilter_.accept(newValue) } }
    let scopeFilter_ = BehaviorRelay(value: SettingsViewModel.arrScopePatternFilters[0])
    var scopeFilter: String { get { scopeFilter_.value } set { scopeFilter_.accept(newValue) } }
    var hasFilter: Bool { !textFilter.isEmpty }

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()

        Observable.combineLatest(arrPatterns_, textFilter_, scopeFilter_).subscribe { [unowned self] _ in
            arrPatternsFiltered = arrPatterns
            if !textFilter.isEmpty {
                arrPatternsFiltered = arrPatternsFiltered.filter { (scopeFilter == "Pattern" ? $0.PATTERN : $0.TAGS).lowercased().contains(textFilter.lowercased()) }
            }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        MPattern.getDataByLang(vmSettings.selectedLang.ID).map { [unowned self] in
            arrPatterns = $0
        }
    }

    static func update(item: MPattern) -> Single<()> {
        MPattern.update(item: item)
    }

    static func create(item: MPattern) -> Single<()> {
        MPattern.create(item: item).map {
            item.ID = $0
        }
    }

    static func delete(_ id: Int) -> Single<()> {
        MPattern.delete(id)
    }

    func newPattern() -> MPattern {
        MPattern().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
