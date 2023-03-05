//
//  WebTextbooksDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class WebTextbooksDetailViewModel: NSObject {
    var vm: WebTextbooksViewModel
    var item: MWebTextbook
    var itemEdit: MWebTextbookEdit
    var isAdd: Bool
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: WebTextbooksViewModel, item: MWebTextbook) {
        self.vm = vm
        self.item = item
        itemEdit = MWebTextbookEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.TITLE.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrWebTextbooks.append(item)
            return WebTextbooksViewModel.create(item: item)
        } else {
            return WebTextbooksViewModel.update(item: item)
        }
    }
}
