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
class LangBlogPostsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPosts = [MLangBlogPost]()
    var currentPost: MLangBlogPost? = nil
    var postContent = ""
    var arrGroups = [MLangBlogGroup]()
    var currentGroup: MLangBlogGroup? = nil

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
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

    static func updateGroup(item: MLangBlogGroup) async {
        await MLangBlogGroup.update(item: item)
    }

    static func createGroup(item: MLangBlogGroup) async {
        _ = await MLangBlogGroup.create(item: item)
    }

    func newGroup() -> MLangBlogGroup {
        MLangBlogGroup().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }

    func selectGroup(_ group: MLangBlogGroup?, complete: @escaping () -> Void) {
        currentGroup = group
        Task {
            complete()
        }
    }

    static func updateBlog(item: MLangBlogPost) async {
        await MLangBlogPost.update(item: item)
    }

    static func createBlog(item: MLangBlogPost) async {
        _ = await MLangBlogPost.create(item: item)
    }

    func newBlog() -> MLangBlogPost {
        MLangBlogPost().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
