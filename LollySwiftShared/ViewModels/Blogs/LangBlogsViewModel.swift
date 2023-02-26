//
//  LangBlogsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class LangBlogsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrGroups = [MLangBlogGroup]()
    var currentGroup: MLangBlogGroup? = nil
    var arrBlogs = [MLangBlog]()
    var currentBlog: MLangBlog? = nil
    var blogContent = ""

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
            arrBlogs = await MLangBlog.getDataByLangGroup(langid: vmSettings.selectedLang.ID, groupid: group?.ID ?? 0)
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

    func selectBlog(_ blog: MLangBlog?, complete: @escaping () -> Void) {
        currentBlog = blog
        Task {
            blogContent = (await MLangBlogContent.getDataById(blog?.ID ?? 0))?.CONTENT ?? ""
            complete()
        }
    }

    static func updateBlog(item: MLangBlog) async {
        await MLangBlog.update(item: item)
    }

    static func createBlog(item: MLangBlog) async {
        _ = await MLangBlog.create(item: item)
    }

    func newBlog() -> MLangBlog {
        MLangBlog().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
