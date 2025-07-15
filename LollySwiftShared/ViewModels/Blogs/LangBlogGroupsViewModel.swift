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

class LangBlogGroupsViewModel: LangBlogViewModel {

    override init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        super.init(settings: settings, complete: complete)
        reloadGroups().subscribe {
            complete()
        } ~ rx.disposeBag
        selectedGroup_.flatMap { [unowned self] _ in
            reloadPosts()
        }.subscribe() ~ rx.disposeBag
    }

    func reloadGroups() -> Single<()> {
        MLangBlogGroup.getDataByLang(vmSettings.selectedLang.ID).map { [unowned self] in
            arrGroups = $0
        }
    }

    func reloadPosts() -> Single<()> {
        MLangBlogPost.getDataByLangGroup(langid: vmSettings.selectedLang.ID, groupid: selectedGroup?.ID ?? 0).map { [unowned self] in
            arrPosts = $0
        }
    }
}
