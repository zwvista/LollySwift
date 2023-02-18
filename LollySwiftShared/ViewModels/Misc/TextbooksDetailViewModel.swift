//
//  TextbooksDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@MainActor
class TextbooksDetailViewModel: NSObject {
    var vm: TextbooksViewModel
    var item: MTextbook
    var itemEdit: MTextbookEdit
    var isAdd: Bool
    @Published var isOKEnabled = false

    init(vm: TextbooksViewModel, item: MTextbook) {
        self.vm = vm
        self.item = item
        itemEdit = MTextbookEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.$TEXTBOOKNAME.map { !$0.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrTextbooks.append(item)
            await TextbooksViewModel.create(item: item)
        } else {
            await TextbooksViewModel.update(item: item)
        }
    }
}
