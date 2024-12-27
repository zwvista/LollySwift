//
//  LangBlogViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class LangBlogViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrGroups = [MLangBlogGroup]()
    var currentGroup: MLangBlogGroup? = nil
    var arrPosts = [MLangBlogPost]()
    var currentPost: MLangBlogPost? = nil
    var postContent = ""

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()
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

    static func updatePost(item: MLangBlogPost) async {
        await MLangBlogPost.update(item: item)
    }

    static func createPost(item: MLangBlogPost) async {
        _ = await MLangBlogPost.create(item: item)
    }

    func newPost() -> MLangBlogPost {
        MLangBlogPost().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
