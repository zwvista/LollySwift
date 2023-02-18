//
//  LangBlogsDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class LangBlogsDetailViewModel: NSObject {
    var vm: LangBlogsViewModel
    var item: MLangBlog
    var itemEdit: MLangBlogEdit
    var isAdd: Bool
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: LangBlogsViewModel, item: MLangBlog) {
        self.vm = vm
        self.item = item
        itemEdit = MLangBlogEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.TITLE.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrLangBlogs.append(item)
            return LangBlogsViewModel.create(item: item)
        } else {
            return LangBlogsViewModel.update(item: item)
        }
    }
}
