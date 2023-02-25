//
//  LangBlogGroupsDetailViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class LangBlogGroupsDetailViewModel: NSObject {
    var vm: LangBlogsViewModel
    var item: MLangBlogGroup
    var itemEdit: MLangBlogGroupEdit
    var isAdd: Bool
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: LangBlogsViewModel, item: MLangBlogGroup) {
        self.vm = vm
        self.item = item
        itemEdit = MLangBlogGroupEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.GROUPNAME.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrGroups.append(item)
            return LangBlogsViewModel.createGroup(item: item)
        } else {
            return LangBlogsViewModel.updateGroup(item: item)
        }
    }
}
