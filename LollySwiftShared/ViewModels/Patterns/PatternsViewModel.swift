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
    var arrWebPages = [MPatternWebPage]()
    var arrPhrases = [MPatternPhrase]()

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        reload().subscribe { complete() } ~ rx.disposeBag
    }
    
    func reload() -> Observable<()> {
        MPattern.getDataByLang(vmSettings.selectedTextbook!.LANGID).map {
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
        MPattern.update(item: item)
    }

    static func create(item: MPattern) -> Observable<Int> {
        MPattern.create(item: item)
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        MPattern.delete(id)
    }
    
    func newPattern() -> MPattern {
        let item = MPattern()
        item.LANGID = vmSettings.selectedLang.ID
        return item
    }
    
    func getWebPages(patternid: Int) -> Observable<()> {
        MPatternWebPage.getDataByPattern(patternid).map {
            self.arrWebPages = $0
        }
    }

    static func updateWebPage(item: MPatternWebPage) -> Observable<()> {
        MPatternWebPage.update(item: item)
    }

    static func createWebPage(item: MPatternWebPage) -> Observable<Int> {
        MPatternWebPage.create(item: item)
    }
    
    static func deleteWebPage(_ id: Int) -> Observable<()> {
        MPatternWebPage.delete(id)
    }
    
    func newPatternWebPage(patternid: Int, pattern: String) -> MPatternWebPage {
        let item = MPatternWebPage()
        item.PATTERNID = patternid
        item.PATTERN = pattern
        item.SEQNUM = (arrWebPages.max { $0.SEQNUM < $1.SEQNUM }?.SEQNUM ?? 0) + 1
        return item
    }
    
    static func updatePhrase(item: MPatternPhrase) -> Observable<()> {
        MLangPhrase.update(item: MLangPhrase(patternitem: item))
    }

    func searchPhrases(patternid: Int) -> Observable<()> {
        MPatternPhrase.getDataByPatternId(patternid).map {
            self.arrPhrases = $0
        }
    }
}
