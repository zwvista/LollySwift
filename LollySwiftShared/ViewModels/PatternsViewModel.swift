//
//  PatternsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PatternsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPatterns = [MPattern]()
    var arrPatternsFiltered: [MPattern]?
    var arrPhrases = [MLangPhrase]()

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        reload().subscribe { complete() }.disposed(by: disposeBag)
    }
    
    func reload() -> Observable<()> {
        return MPattern.getDataByLang(vmSettings.selectedTextbook!.LANGID).map {
            self.arrPatterns = $0
        }
    }
    
    func applyFilters(textFilter: String, scope: String) {
        if textFilter.isEmpty {
            arrPatternsFiltered = nil
        } else {
            arrPatternsFiltered = arrPatterns
            if !textFilter.isEmpty {
                arrPatternsFiltered = arrPatternsFiltered!.filter { (scope == "Pattern" ? $0.PATTERN : $0.NOTE ?? "").lowercased().contains(textFilter.lowercased()) }
            }
        }
    }
    
    static func update(item: MPattern) -> Observable<()> {
        return MPattern.update(item: item)
    }

    static func create(item: MPattern) -> Observable<Int> {
        return MPattern.create(item: item)
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MPattern.delete(id)
    }
    
    func newLangPattern() -> MPattern {
        let item = MPattern()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }
}
