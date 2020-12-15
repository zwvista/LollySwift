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
    var selectedPatternItem: MPattern?
    var selectedPattern: String { selectedPatternItem?.PATTERN ?? "" }
    var selectedPatternID: Int { selectedPatternItem?.ID ?? 0 }
    var arrWebPages = [MPatternWebPage]()
    var currentWebPageIndex = 0
    var currentWebPageTitle: String { arrWebPages[currentWebPageIndex].TITLE }
    func next(_ delta: Int) {
        currentWebPageIndex = (currentWebPageIndex + delta + arrWebPages.count) % arrWebPages.count
    }

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        reload().subscribe(onNext: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Observable<()> {
        MPattern.getDataByLang(vmSettings.selectedLang.ID).map {
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
    
    func getWebPages() -> Observable<()> {
        MPatternWebPage.getDataByPattern(selectedPatternID).map {
            self.arrWebPages = $0
        }
    }

    static func updateWebPage(item: MPatternWebPage) -> Observable<()> {
        MWebPage.update(item: item)
    }

    static func createWebPage(item: MPatternWebPage) -> Observable<()> {
        MWebPage.create(item: item).map {
            item.WEBPAGEID = $0
        }
    }

    static func updatePatternWebPage(item: MPatternWebPage) -> Observable<()> {
        MPatternWebPage.update(item: item)
    }

    static func createPatternWebPage(item: MPatternWebPage) -> Observable<()> {
        MPatternWebPage.create(item: item).map {
            item.ID = $0
        }
    }

    static func deleteWebPage(_ id: Int) -> Observable<()> {
        MPatternWebPage.delete(id)
    }
    
    func newPatternWebPage() -> MPatternWebPage {
        let item = MPatternWebPage()
        item.PATTERNID = selectedPatternID
        item.PATTERN = selectedPattern
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
