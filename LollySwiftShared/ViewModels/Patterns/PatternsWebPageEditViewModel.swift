//
//  PatternsDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/21.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class PatternsWebPageEditViewModel: NSObject {
    var vm: PatternsViewModel!
    var item: MPatternWebPage!
    var itemEdit: MPatternWebPageEdit!
    var isAddPatternWebPage: Bool!
    var isAddWebPage: Bool!
    var isOKEnabled = BehaviorRelay(value: false)

    init(vm: PatternsViewModel, item: MPatternWebPage) {
        self.vm = vm
        self.item = item
        itemEdit = MPatternWebPageEdit(x: item)
        isAddPatternWebPage = item.WEBPAGEID == 0
        isAddWebPage = item.ID == 0
        _ = Observable.zip(itemEdit.TITLE, itemEdit.URL) .map { !$0.0.isEmpty && !$0.1.isEmpty } ~> isOKEnabled
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        return (isAddPatternWebPage ? PatternsViewModel.createWebPage(item: item) : PatternsViewModel.updateWebPage(item: item)).flatMap {
            self.isAddWebPage ? PatternsViewModel.createPatternWebPage(item: self.item) : PatternsViewModel.updatePatternWebPage(item: self.item)
        }
    }
}
