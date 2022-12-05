//
//  PatternsWebPagesDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

class PatternsWebPagesDetailViewModel: NSObject {
    var item: MPatternWebPage!
    var itemEdit: MPatternWebPageEdit!
    var isAddPatternWebPage: Bool!
    var isAddWebPage: Bool!
    @Published var isOKEnabled = false

    init(item: MPatternWebPage) {
        self.item = item
        itemEdit = MPatternWebPageEdit(x: item)
        isAddWebPage = item.WEBPAGEID == 0
        isAddPatternWebPage = item.ID == 0
        super.init()
        itemEdit.$TITLE.combineLatest(itemEdit.$URL).map { !$0.0.isEmpty && !$0.1.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: item)
        isAddWebPage ? await PatternsWebPagesViewModel.createWebPage(item: item) : await PatternsWebPagesViewModel.updateWebPage(item: item)
        isAddPatternWebPage ? await PatternsWebPagesViewModel.createPatternWebPage(item: item) : await PatternsWebPagesViewModel.updatePatternWebPage(item: item)
    }
}
