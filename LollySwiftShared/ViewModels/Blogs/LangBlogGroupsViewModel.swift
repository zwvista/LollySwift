//
//  LangBlogGroupsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class LangBlogGroupsViewModel: LangBlogViewModel {

    override init() {
        super.init()
        $selectedGroup.didSet.sink { [unowned self] _ in
            Task {
                await reloadPosts()
            }
        } ~ subscriptions
    }

    func reloadGroups() async {
        arrGroupsAll = await MLangBlogGroup.getDataByLang(vmSettings.selectedLang.ID)
    }

    func reloadPosts() async {
        arrPostsAll = await MLangBlogPost.getDataByLangGroup(langid: vmSettings.selectedLang.ID, groupid: selectedGroup?.ID ?? 0)
    }
}
