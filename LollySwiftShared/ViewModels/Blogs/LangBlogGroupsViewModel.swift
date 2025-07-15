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

    override init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        super.init(settings: settings, complete: complete)
        Task {
            await reloadGroups()
            complete()
        }
        $selectedGroup.didSet.sink { [unowned self] _ in
            Task {
                await reloadPosts()
            }
        } ~ subscriptions
    }

    func reloadGroups() async {
        arrGroups = await MLangBlogGroup.getDataByLang(vmSettings.selectedLang.ID)
    }

    func reloadPosts() async {
        arrPosts = await MLangBlogPost.getDataByLangGroup(langid: vmSettings.selectedLang.ID, groupid: selectedGroup?.ID ?? 0)
    }
}
