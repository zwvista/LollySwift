//
//  PatternsWebPagesDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class PatternsWebPagesDetailViewModel: NSObject {
    var item: MPatternWebPage!
    var itemEdit: MPatternWebPageEdit!
    var isAddPatternWebPage: Bool!
    var isAddWebPage: Bool!
    let isOKEnabled = BehaviorRelay(value: false)

    init(item: MPatternWebPage) {
        self.item = item
        itemEdit = MPatternWebPageEdit(x: item)
        isAddWebPage = item.WEBPAGEID == 0
        isAddPatternWebPage = item.ID == 0
        _ = Observable.combineLatest(itemEdit.TITLE, itemEdit.URL).map { !$0.0.isEmpty && !$0.1.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        return (isAddWebPage ? PatternsWebPagesViewModel.createWebPage(item: item) : PatternsWebPagesViewModel.updateWebPage(item: item)).flatMap {
            self.isAddPatternWebPage ? PatternsWebPagesViewModel.createPatternWebPage(item: self.item) : PatternsWebPagesViewModel.updatePatternWebPage(item: self.item)
        }
    }
}
