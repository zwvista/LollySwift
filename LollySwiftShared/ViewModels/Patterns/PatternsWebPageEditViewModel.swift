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
    var isAdd: Bool!
    var isOKEnabled = BehaviorRelay(value: false)

    init(vm: PatternsViewModel, item: MPatternWebPage) {
        self.vm = vm
        self.item = item
        itemEdit = MPatternWebPageEdit(x: item)
        isAdd = item.WEBPAGEID == 0
        _ = itemEdit.PATTERN.map { !$0.isEmpty } ~> isOKEnabled
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrWebPages.append(item)
            return PatternsViewModel.createWebPage(item: item)
        } else {
            return PatternsViewModel.updateWebPage(item: item)
        }
    }
}
