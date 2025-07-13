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

    override init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        super.init(settings: settings, complete: complete)
        Task {
            await reloadGroups()
            complete()
        }
    }

    func selectGroup(_ group: MLangBlogGroup?, complete: @escaping () -> Void) {
        selectedGroup = group
        Task {
            await reloadPosts()
            complete()
        }
    }

    func selectPost(_ blog: MLangBlogPost?, complete: @escaping () -> Void) {
        selectedPost = blog
        Task {
            postContent = (await MLangBlogPostContent.getDataById(blog?.ID ?? 0))?.CONTENT ?? ""
            complete()
        }
    }

    func reloadGroups() async {
        arrGroups = await MLangBlogGroup.getDataByLang(vmSettings.selectedLang.ID)
    }

    func reloadPosts() async {
        arrPosts = await MLangBlogPost.getDataByLangGroup(langid: vmSettings.selectedLang.ID, groupid: selectedGroup?.ID ?? 0)
    }
}
