//
//  LangBlogViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class LangBlogViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrGroups = [MLangBlogGroup]()
    var currentGroup: MLangBlogGroup? = nil
    var arrPosts = [MLangBlogPost]()
    var currentPost: MLangBlogPost? = nil
    var postContent = ""

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
    }

    static func updateGroup(item: MLangBlogGroup) -> Single<()> {
        MLangBlogGroup.update(item: item)
    }

    static func createGroup(item: MLangBlogGroup) -> Single<()> {
        MLangBlogGroup.create(item: item).map { _ in }
    }

    func newGroup() -> MLangBlogGroup {
        MLangBlogGroup().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }

    static func updatePost(item: MLangBlogPost) -> Single<()> {
        MLangBlogPost.update(item: item)
    }

    static func createPost(item: MLangBlogPost) -> Single<()> {
        MLangBlogPost.create(item: item).map { _ in }
    }

    func newPost() -> MLangBlogPost {
        MLangBlogPost().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
