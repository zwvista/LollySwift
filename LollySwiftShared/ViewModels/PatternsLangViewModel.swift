//
//  PatternsLangViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PatternsLangViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPatterns = [MLangPattern]()
    var arrPatternsFiltered: [MLangPattern]?
    var arrPhrases = [MLangPhrase]()

    public init(settings: SettingsViewModel, disposeBag: DisposeBag, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        reload().subscribe { complete() }.disposed(by: disposeBag)
    }
    
    func reload() -> Observable<()> {
        return MLangPattern.getDataByLang(vmSettings.selectedTextbook!.LANGID).map {
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
    
    static func update(item: MLangPattern) -> Observable<()> {
        return MLangPattern.update(item: item)
    }

    static func create(item: MLangPattern) -> Observable<Int> {
        return MLangPattern.create(item: item)
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        return MLangPattern.delete(id)
    }
}
