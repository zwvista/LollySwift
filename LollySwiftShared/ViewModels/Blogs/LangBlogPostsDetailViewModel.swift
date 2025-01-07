//
//  LangBlogPostsDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class LangBlogPostsDetailViewModel: NSObject {
    var vm: LangBlogViewModel
    var itemPost: MLangBlogPost
    var itemEdit: MLangBlogPostEdit
    var isAdd: Bool
    var itemGroup: MLangBlogGroup?
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: LangBlogViewModel, itemPost: MLangBlogPost, itemGroup: MLangBlogGroup? = nil) {
        self.vm = vm
        self.itemPost = itemPost
        self.itemGroup = itemGroup
        itemEdit = MLangBlogPostEdit(x: itemPost)
        isAdd = itemPost.ID == 0
        super.init()
        _ = itemEdit.TITLE.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: itemPost)
        if isAdd {
            vm.arrPosts.append(itemPost)
            let itemGP = MLangBlogGP()
            itemGP.GROUPID = itemGroup!.ID
            return LangBlogViewModel.createPost(item: itemPost).map {
                itemGP.POSTID = $0
                _ = MLangBlogGP.create(item: itemGP)
            }
        } else {
            return LangBlogViewModel.updatePost(item: itemPost)
        }
    }
}
