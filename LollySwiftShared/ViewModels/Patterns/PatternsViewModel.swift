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
import Then

class PatternsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPatterns = [MPattern]()
    var arrPatternsFiltered: [MPattern]?
    var selectedPatternItem: MPattern?
    var selectedPattern: String { selectedPatternItem?.PATTERN ?? "" }
    var selectedPatternID: Int { selectedPatternItem?.ID ?? 0 }
    let textFilter = BehaviorRelay(value: "")
    let scopeFilter = BehaviorRelay(value: SettingsViewModel.arrScopePatternFilters[0])

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        reload().subscribe(onCompleted: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Completable {
        MPattern.getDataByLang(vmSettings.selectedLang.ID).flatMapCompletable {
            self.arrPatterns = $0
            return Completable.empty()
        }
    }
    
    func applyFilters() {
        if textFilter.value.isEmpty {
            arrPatternsFiltered = nil
        } else {
            arrPatternsFiltered = arrPatterns
            if !textFilter.value.isEmpty {
                arrPatternsFiltered = arrPatternsFiltered!.filter { (scopeFilter.value == "Pattern" ? $0.PATTERN : scopeFilter.value == "Note" ? $0.NOTE : $0.TAGS).lowercased().contains(textFilter.value.lowercased()) }
            }
        }
    }
    
    static func update(item: MPattern) -> Completable {
        MPattern.update(item: item)
    }

    static func create(item: MPattern) -> Completable {
        MPattern.create(item: item).flatMapCompletable {
            item.ID = $0
            return Completable.empty()
        }
    }
    
    static func delete(_ id: Int) -> Completable {
        MPattern.delete(id)
    }
    
    func newPattern() -> MPattern {
        MPattern().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
