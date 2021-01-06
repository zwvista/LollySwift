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

class PatternsDetailViewModel: NSObject {
    var vm: PatternsViewModel!
    var item: MPattern!
    var itemEdit: MPatternEdit!
    var isAdd: Bool!
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: PatternsViewModel, item: MPattern) {
        self.vm = vm
        self.item = item
        itemEdit = MPatternEdit(x: item)
        isAdd = item.ID == 0
        _ = itemEdit.PATTERN.map { !$0.isEmpty } ~> isOKEnabled
    }
    
    func onOK() -> Observable<()> {
        itemEdit.save(to: item)
        item.PATTERN = vm.vmSettings.autoCorrectInput(text: item.PATTERN)
        if isAdd {
            vm.arrPatterns.append(item)
            return PatternsViewModel.create(item: item)
        } else {
            return PatternsViewModel.update(item: item)
        }
    }
}
