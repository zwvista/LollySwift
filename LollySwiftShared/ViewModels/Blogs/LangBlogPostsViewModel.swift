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

    override init(settings: SettingsViewModel) {
        super.init(settings: settings)
        selectedPost_.flatMap { [unowned self] _ in
            reloadGroups()
        }.subscribe() ~ rx.disposeBag
    }

    func reloadPosts() -> Single<()> {
        MLangBlogPost.getDataByLang(vmSettings.selectedLang.ID).map { [unowned self] in
             arrPosts = $0
        }
    }

    func reloadGroups() -> Single<()> {
        MLangBlogGroup.getDataByLangPost(langid: vmSettings.selectedLang.ID, postid: selectedPost?.ID ?? 0).map { [unowned self] in
            arrGroups = $0
        }
    }
}
