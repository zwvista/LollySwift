//
//  LangBlogPostsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class LangBlogPostsViewModel: LangBlogViewModel {

    override init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        super.init(settings: settings, needCopy: needCopy, complete: complete)
        MLangBlogPost.getDataByLang(vmSettings.selectedLang.ID).subscribe { [unowned self] in
            arrPosts = $0
            complete()
        } ~ rx.disposeBag
    }

    func selectPost(_ post: MLangBlogPost?, complete: @escaping () -> Void) {
        currentPost = post
        MLangBlogPostContent.getDataById(post?.ID ?? 0).subscribe { [unowned self] in
            postContent = $0?.CONTENT ?? ""
        } ~ rx.disposeBag
        MLangBlogGroup.getDataByLangPost(langid: vmSettings.selectedLang.ID, postid: post?.ID ?? 0).subscribe { [unowned self] in
            arrGroups = $0
            complete()
        } ~ rx.disposeBag
    }

    func selectGroup(_ group: MLangBlogGroup?, complete: @escaping () -> Void) {
        currentGroup = group
        complete()
    }
}
