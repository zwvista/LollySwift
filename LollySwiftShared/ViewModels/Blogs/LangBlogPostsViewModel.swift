//
//  LangBlogPostsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class LangBlogPostsViewModel: LangBlogViewModel {

    override init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        super.init(settings: settings, needCopy: needCopy, complete: complete)
        Task {
            arrPosts = await MLangBlogPost.getDataByLang(settings.selectedLang.ID)
            complete()
        }
    }

    func selectPost(_ post: MLangBlogPost?, complete: @escaping () -> Void) {
        currentPost = post
        Task {
            postContent = (await MLangBlogPostContent.getDataById(post?.ID ?? 0))?.CONTENT ?? ""
            arrGroups = await MLangBlogGroup.getDataByLangPost(langid: vmSettings.selectedLang.ID, postid: post?.ID ?? 0)
            complete()
        }
    }

    func selectGroup(_ group: MLangBlogGroup?, complete: @escaping () -> Void) {
        currentGroup = group
        Task {
            complete()
        }
    }
}
