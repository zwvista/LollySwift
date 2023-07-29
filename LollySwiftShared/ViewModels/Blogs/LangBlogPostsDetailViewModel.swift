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
    var vm: LangBlogGroupsViewModel
    var item: MLangBlogPost
    var itemEdit: MLangBlogPostEdit
    var isAdd: Bool
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: LangBlogGroupsViewModel, item: MLangBlogPost) {
        self.vm = vm
        self.item = item
        itemEdit = MLangBlogPostEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.TITLE.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrPosts.append(item)
            return LangBlogGroupsViewModel.createBlog(item: item)
        } else {
            return LangBlogGroupsViewModel.updateBlog(item: item)
        }
    }
}
