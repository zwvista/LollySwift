//
//  TextbooksDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class TextbooksDetailViewModel: NSObject {
    var vm: TextbooksViewModel
    var item: MTextbook
    var itemEdit: MTextbookEdit
    var isAdd: Bool
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: TextbooksViewModel, item: MTextbook) {
        self.vm = vm
        self.item = item
        itemEdit = MTextbookEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.TEXTBOOKNAME.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrTextbooks.append(item)
            return TextbooksViewModel.create(item: item)
        } else {
            return TextbooksViewModel.update(item: item)
        }
    }
}
