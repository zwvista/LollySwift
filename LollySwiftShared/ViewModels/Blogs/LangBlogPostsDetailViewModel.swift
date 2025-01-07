//
//  LangBlogPostsDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation

@MainActor
class LangBlogPostsDetailViewModel: NSObject {
    var vm: LangBlogViewModel
    var itemPost: MLangBlogPost
    var itemEdit: MLangBlogPostEdit
    var isAdd: Bool
    var itemGroup: MLangBlogGroup?
    @Published var isOKEnabled = false

    init(vm: LangBlogViewModel, itemPost: MLangBlogPost, itemGroup: MLangBlogGroup? = nil) {
        self.vm = vm
        self.itemPost = itemPost
        self.itemGroup = itemGroup
        itemEdit = MLangBlogPostEdit(x: itemPost)
        isAdd = itemPost.ID == 0
        super.init()
        _ = itemEdit.$TITLE.map { !$0.isEmpty }.eraseToAnyPublisher() ~> $isOKEnabled
    }

    func onOK() async {
        itemEdit.save(to: itemPost)
        if isAdd {
            vm.arrPosts.append(itemPost)
            let itemGP = MLangBlogGP()
            itemGP.GROUPID = itemGroup!.ID
            itemGP.POSTID = await LangBlogViewModel.createPost(item: itemPost)
            _ = await MLangBlogGP.create(item: itemGP)
        } else {
            await LangBlogViewModel.updatePost(item: itemPost)
        }
    }
}
