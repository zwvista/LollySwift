//
//  LangBlogSelectGroupsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@MainActor
class LangBlogSelectGroupsViewModel: NSObject {
    var vm: LangBlogViewModel
    var item: MLangBlogPost
    var itemEdit: MLangBlogPostEdit
    var isAdd: Bool
    @Published var isOKEnabled = false

    init(vm: LangBlogViewModel, item: MLangBlogPost) {
        self.vm = vm
        self.item = item
        itemEdit = MLangBlogPostEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.$TITLE.map { !$0.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrPosts.append(item)
            await LangBlogViewModel.createPost(item: item)
        } else {
            await LangBlogViewModel.updatePost(item: item)
        }
    }
}
