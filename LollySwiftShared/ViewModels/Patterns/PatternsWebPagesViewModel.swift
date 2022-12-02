//
//  PatternsWebPagesViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

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

    func getWebPages() async {
        if selectedPatternItem == nil {
            arrWebPages.removeAll()
        } else {
            arrWebPages = await MPatternWebPage.getDataByPattern(selectedPatternItem!.ID)
        }
    }

    static func updateWebPage(item: MPatternWebPage) async {
        await MWebPage.updatePattern(item: item)
    }

    static func createWebPage(item: MPatternWebPage) async {
        item.WEBPAGEID = await MWebPage.createPattern(item: item)
    }

    static func updatePatternWebPage(item: MPatternWebPage) async {
        await MPatternWebPage.update(item: item)
    }

    static func createPatternWebPage(item: MPatternWebPage) async {
        item.ID = await MPatternWebPage.create(item: item)
    }

    static func deleteWebPage(_ id: Int) async {
        await MPatternWebPage.delete(id)
    }

    func newPatternWebPage() -> MPatternWebPage {
        let item = MPatternWebPage()
        item.PATTERNID = selectedPatternItem!.ID
        item.PATTERN = selectedPatternItem!.PATTERN
        item.SEQNUM = (arrWebPages.max { $0.SEQNUM < $1.SEQNUM }?.SEQNUM ?? 0) + 1
        return item
    }

    func reindexWebPage(complete: @escaping (Int) -> Void) async {
        for i in 1...arrWebPages.count {
            let item = arrWebPages[i - 1]
            guard item.SEQNUM != i else {continue}
            item.SEQNUM = i
            await MPatternWebPage.update(item.ID, seqnum: item.SEQNUM)
            complete(i - 1)
        }
    }
}
