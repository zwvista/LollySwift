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
    var vm: LangBlogGroupsViewModel
    var item: MLangBlogGroup
    var itemEdit: MLangBlogGroupEdit
    var isAdd: Bool
    let isOKEnabled = BehaviorRelay(value: false)

    init(vm: LangBlogGroupsViewModel, item: MLangBlogGroup) {
        self.vm = vm
        self.item = item
        itemEdit = MLangBlogGroupEdit(x: item)
        isAdd = item.ID == 0
        super.init()
        _ = itemEdit.LANGBLOGGROUPNAME.map { !$0.isEmpty } ~> isOKEnabled
    }

    func onOK() -> Single<()> {
        itemEdit.save(to: item)
        if isAdd {
            vm.arrLangBlogGroups.append(item)
            return LangBlogGroupsViewModel.create(item: item)
        } else {
            return LangBlogGroupsViewModel.update(item: item)
        }
    }
}
