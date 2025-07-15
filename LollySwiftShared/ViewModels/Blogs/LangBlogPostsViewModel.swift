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

    override init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        super.init(settings: settings, complete: complete)
        Task {
            await reloadPosts()
            complete()
        }
        $selectedPost.didSet.sink { [unowned self] _ in
            Task {
                await reloadGroups()
            }
        } ~ subscriptions
    }

    func reloadPosts() async {
        arrPosts = await MLangBlogPost.getDataByLang(vmSettings.selectedLang.ID)
    }

    func reloadGroups() async {
        arrGroups = await MLangBlogGroup.getDataByLangPost(langid: vmSettings.selectedLang.ID, postid: selectedPost?.ID ?? 0)
    }
}
