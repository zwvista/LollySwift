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
    var item: MLangBlogPost
    var groupsAvailable = [MLangBlogGroup]()
    var groupsSelected = [MLangBlogGroup]()

    init(item: MLangBlogPost, complete: @escaping () -> Void) {
        self.item = item
        super.init()
        Task {
            groupsSelected = await MLangBlogGroup.getDataByLangPost(langid: item.LANGID, postid: item.ID)
            groupsAvailable = (await MLangBlogGroup.getDataByLang(item.LANGID)).filter { o in
                groupsSelected.allSatisfy { $0.ID != o.ID }
            }
            complete()
        }
    }

    func onOK() async {
    }
}
