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
class LangBlogGroupsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrGroups = [MLangBlogGroup]()
    var currentGroup: MLangBlogGroup? = nil
    var arrPosts = [MLangBlogPost]()
    var currentPost: MLangBlogPost? = nil
    var postContent = ""

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
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

    func selectPost(_ blog: MLangBlogPost?, complete: @escaping () -> Void) {
        currentPost = blog
        Task {
            postContent = (await MLangBlogPostContent.getDataById(blog?.ID ?? 0))?.CONTENT ?? ""
            complete()
        }
    }

    static func updateBlog(item: MLangBlogPost) async {
        await MLangBlogPost.update(item: item)
    }

    static func createBlog(item: MLangBlogPost) async {
        _ = await MLangBlogPost.create(item: item)
    }

    func newPost() -> MLangBlogPost {
        MLangBlogPost().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
