//
//  LangBlogGroupsDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@MainActor
class LangBlogGroupsDetailViewModel: NSObject {
    var vm: LangBlogGroupsViewModel
    var item: MLangBlogGroup
    var itemEdit: MLangBlogGroupEdit
    var isAdd: Bool
    @Published var isOKEnabled = false

    init(vm: LangBlogGroupsViewModel, item: MLangBlogGroup) {
        self.vm = vm
        self.item = item
        itemEdit = MLangBlogGroupEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.$LANGBLOGGROUPNAME.map { !$0.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrLangBlogGroups.append(item)
            await LangBlogGroupsViewModel.create(item: item)
        } else {
            await LangBlogGroupsViewModel.update(item: item)
        }
    }
}
