//
//  LangBlogGroupsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

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
        MLangBlogGroup.getDataByLang(settings.selectedLang.ID).subscribe { [unowned self] in
            arrGroups = $0
            complete()
        } ~ rx.disposeBag
    }

    func selectGroup(_ group: MLangBlogGroup?, complete: @escaping () -> Void) {
        currentGroup = group
        MLangBlogPost.getDataByLangGroup(langid: vmSettings.selectedLang.ID, groupid: group?.ID ?? 0).subscribe { [unowned self] in
            arrPosts = $0
            complete()
        } ~ rx.disposeBag
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

    func selectPost(_ post: MLangBlogPost?, complete: @escaping () -> Void) {
        currentPost = post
        MLangBlogPostContent.getDataById(post?.ID ?? 0).subscribe { [unowned self] in
            postContent = $0?.CONTENT ?? ""
            complete()
        } ~ rx.disposeBag
    }

    static func updateBlog(item: MLangBlogPost) -> Single<()> {
        MLangBlogPost.update(item: item)
    }

    static func createBlog(item: MLangBlogPost) -> Single<()> {
        MLangBlogPost.create(item: item).map { _ in }
    }

    func newPost() -> MLangBlogPost {
        MLangBlogPost().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
