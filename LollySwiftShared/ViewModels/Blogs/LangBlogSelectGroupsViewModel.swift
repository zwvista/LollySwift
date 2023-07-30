//
//  LangBlogSelectGroupsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class LangBlogSelectGroupsViewModel: NSObject {
    var itemPost: MLangBlogPost
    var groupsAvailable = [MLangBlogGroup]()
    var groupsSelected = [MLangBlogGroup]()
    var groupsSelectedOriginal = [MLangBlogGroup]()

    init(item: MLangBlogPost, complete: @escaping () -> Void) {
        self.itemPost = item
        super.init()
        Single.zip(MLangBlogGroup.getDataByLangPost(langid: item.LANGID, postid: item.ID),
                   MLangBlogGroup.getDataByLang(item.LANGID)).subscribe { [unowned self] result in
            groupsSelected = result.0
            groupsAvailable = result.1.filter { o in
                groupsSelected.allSatisfy { $0.ID != o.ID }
            }
            complete()
        } ~ rx.disposeBag
    }

    func updateGroups() {
        groupsAvailable.sort { $0.GROUPNAME < $1.GROUPNAME }
        groupsSelected.sort { $0.GROUPNAME < $1.GROUPNAME }
    }
    func addGroups(arr: [MLangBlogGroup]) {
        groupsAvailable.removeAll { o in arr.contains(o) }
        groupsSelected.append(contentsOf: arr)
        updateGroups()
    }
    func removeGroups(arr: [MLangBlogGroup]) {
        groupsAvailable.append(contentsOf: arr)
        groupsSelected.removeAll { o in arr.contains(o) }
        updateGroups()
    }
    func removeAllGroups() {
        groupsAvailable.append(contentsOf: groupsSelected)
        groupsSelected.removeAll()
        updateGroups()
    }
    func onOK() -> Single<()> {
        let groupsRemove = groupsSelectedOriginal.filter { o in
            groupsSelected.allSatisfy { $0.ID != o.ID }
        }
        let groupsAdd = groupsSelected.filter { o in
            groupsSelectedOriginal.allSatisfy { $0.ID != o.ID }
        }
        var o2 = Single.just(())
        for o in groupsRemove {
            o2 = o2.flatMap { MLangBlogGP.delete(o.GPID) }
        }
        for o in groupsAdd {
            let item = MLangBlogGP().then {
                $0.GROUPID = o.ID
                $0.POSTID = itemPost.ID
            }
            o2 = o2.flatMap { MLangBlogGP.create(item: item).map {_ in } }
        }
        return o2
    }
}
