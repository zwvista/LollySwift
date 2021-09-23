//
//  PatternsWebPagesViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PatternsWebPagesViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var selectedPatternItem: MPattern?
    var arrWebPages = [MPatternWebPage]()
    var currentWebPageIndex = 0
    var currentWebPage: MPatternWebPage { arrWebPages[currentWebPageIndex] }
    func next(_ delta: Int) {
        currentWebPageIndex = (currentWebPageIndex + delta + arrWebPages.count) % arrWebPages.count
    }

    public init(settings: SettingsViewModel, needCopy: Bool) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
    }
    
    func getWebPages() -> Single<()> {
        if selectedPatternItem == nil {
            arrWebPages.removeAll()
            return Single.just(())
        } else {
            return MPatternWebPage.getDataByPattern(selectedPatternItem!.ID).map {
                self.arrWebPages = $0
            }
        }
    }

    static func updateWebPage(item: MPatternWebPage) -> Single<()> {
        MWebPage.update(item: item)
    }

    static func createWebPage(item: MPatternWebPage) -> Single<()> {
        MWebPage.create(item: item).map {
            item.WEBPAGEID = $0
        }
    }

    static func updatePatternWebPage(item: MPatternWebPage) -> Single<()> {
        MPatternWebPage.update(item: item)
    }

    static func createPatternWebPage(item: MPatternWebPage) -> Single<()> {
        MPatternWebPage.create(item: item).map {
            item.ID = $0
        }
    }

    static func deleteWebPage(_ id: Int) -> Single<()> {
        MPatternWebPage.delete(id)
    }

    func newPatternWebPage() -> MPatternWebPage {
        let item = MPatternWebPage()
        item.PATTERNID = selectedPatternItem!.ID
        item.PATTERN = selectedPatternItem!.PATTERN
        item.SEQNUM = (arrWebPages.max { $0.SEQNUM < $1.SEQNUM }?.SEQNUM ?? 0) + 1
        return item
    }

    func reindexWebPage(complete: @escaping (Int) -> ()) {
        for i in 1...arrWebPages.count {
            let item = arrWebPages[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            MPatternWebPage.update(item.ID, seqnum: item.SEQNUM).subscribe(onSuccess: {
                complete(i - 1)
            }) ~ rx.disposeBag
        }
    }
}
