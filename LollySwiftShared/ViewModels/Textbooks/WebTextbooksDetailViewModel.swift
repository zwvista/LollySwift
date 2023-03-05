//
//  WebTextbooksDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@MainActor
class WebTextbooksDetailViewModel: NSObject, ObservableObject {
    var vm: WebTextbooksViewModel
    var item: MWebTextbook
    var itemEdit: MWebTextbookEdit
    var isAdd: Bool
    @Published var isOKEnabled = false

    init(vm: WebTextbooksViewModel, item: MWebTextbook) {
        self.vm = vm
        self.item = item
        itemEdit = MWebTextbookEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.$TITLE.map { !$0.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrWebTextbooks.append(item)
            await WebTextbooksViewModel.create(item: item)
        } else {
            await WebTextbooksViewModel.update(item: item)
        }
    }
}
