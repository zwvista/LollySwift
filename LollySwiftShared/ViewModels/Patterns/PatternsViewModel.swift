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

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        reload().subscribe(onNext: { complete() }) ~ rx.disposeBag
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
                arrPatternsFiltered = arrPatternsFiltered!.filter { (scope == "Pattern" ? $0.PATTERN : scope == "Note" ? $0.NOTE : $0.TAGS).lowercased().contains(textFilter.lowercased()) }
            }
        }
    }
    
    static func update(item: MPattern) -> Observable<()> {
        MPattern.update(item: item)
    }

    static func create(item: MPattern) -> Observable<()> {
        MPattern.create(item: item).map {
            item.ID = $0
        }
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
        
    func reindexWebPage(complete: @escaping (Int) -> ()) {
        for i in 1...arrWebPages.count {
            let item = arrWebPages[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            MPatternWebPage.update(item.ID, seqnum: item.SEQNUM).subscribe(onNext: {
                complete(i - 1)
            }) ~ rx.disposeBag
        }
    }
}
