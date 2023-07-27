//
//  LangBlogsDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@MainActor
class LangBlogsDetailViewModel: NSObject {
    var vm: LangBlogsViewModel
    var item: MLangBlogPost
    var itemEdit: MLangBlogPostEdit
    var isAdd: Bool
    @Published var isOKEnabled = false

    init(vm: LangBlogsViewModel, item: MLangBlogPost) {
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
            vm.arrBlogs.append(item)
            await LangBlogsViewModel.createBlog(item: item)
        } else {
            await LangBlogsViewModel.updateBlog(item: item)
        }
    }
}
