//
//  LangBlogsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

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
        MLangBlogGroup.getDataByLang(settings.selectedLang.ID).subscribe { [unowned self] in
            arrGroups = $0
            complete()
        } ~ rx.disposeBag
    }

    func selectGroup(_ group: MLangBlogGroup?, complete: @escaping () -> Void) {
        currentGroup = group
        MLangBlog.getDataByLangGroup(langid: vmSettings.selectedLang.ID, groupid: group?.ID ?? 0).subscribe { [unowned self] in
            arrBlogs = $0
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

    func selectBlog(_ blog: MLangBlog?, complete: @escaping () -> Void) {
        currentBlog = blog
        MLangBlogContent.getDataById(blog?.ID ?? 0).subscribe { [unowned self] in
            blogContent = $0?.CONTENT ?? ""
            complete()
        } ~ rx.disposeBag
    }

    static func updateBlog(item: MLangBlog) -> Single<()> {
        MLangBlog.update(item: item)
    }

    static func createBlog(item: MLangBlog) -> Single<()> {
        MLangBlog.create(item: item).map { _ in }
    }

    func newBlog() -> MLangBlog {
        MLangBlog().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
