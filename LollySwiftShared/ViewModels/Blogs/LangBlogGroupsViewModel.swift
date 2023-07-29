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

    override init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        super.init(settings: settings, needCopy: needCopy, complete: complete)
        Task {
            arrGroups = await MLangBlogGroup.getDataByLang(settings.selectedLang.ID)
            complete()
        }
    }

    func selectGroup(_ group: MLangBlogGroup?, complete: @escaping () -> Void) {
        currentGroup = group
        Task {
            arrPosts = await MLangBlogPost.getDataByLangGroup(langid: vmSettings.selectedLang.ID, groupid: group?.ID ?? 0)
            complete()
        }
    }

    func selectPost(_ blog: MLangBlogPost?, complete: @escaping () -> Void) {
        currentPost = blog
        Task {
            postContent = (await MLangBlogPostContent.getDataById(blog?.ID ?? 0))?.CONTENT ?? ""
            complete()
        }
    }
}
