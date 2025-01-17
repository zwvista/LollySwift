//
//  LangBlogViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding
import Then

class LangBlogViewModel: NSObject {
    var vmSettings: SettingsViewModel
    let arrGroups_ = BehaviorRelay(value: [MLangBlogGroup]())
    var arrGroups: [MLangBlogGroup] { get { arrGroups_.value } set { arrGroups_.accept(newValue) } }
    var currentGroup: MLangBlogGroup? = nil

    let arrPosts_ = BehaviorRelay(value: [MLangBlogPost]())
    var arrPosts: [MLangBlogPost] { get { arrPosts_.value } set { arrPosts_.accept(newValue) } }
    var currentPost: MLangBlogPost? = nil
    let postFilter_ = BehaviorRelay(value: "")
    var postFilter: String { get { postFilter_.value } set { postFilter_.accept(newValue) } }
    let arrPostsFiltered_ = BehaviorRelay(value: [MLangBlogPost]())
    var arrPostsFiltered: [MLangBlogPost] { get { arrPostsFiltered_.value } set { arrPostsFiltered_.accept(newValue) } }
    var hasPostFilter: Bool { !postFilter.isEmpty }
    var postContent = ""

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()

        Observable.combineLatest(arrPosts_, postFilter_).subscribe { [unowned self] _ in
            arrPostsFiltered = !hasPostFilter ? arrPosts : arrPosts.filter { $0.TITLE.lowercased().contains(postFilter.lowercased()) }
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

    static func updatePost(item: MLangBlogPost) -> Single<()> {
        MLangBlogPost.update(item: item)
    }

    static func createPost(item: MLangBlogPost) -> Single<Int> {
        MLangBlogPost.create(item: item)
    }

    func newPost() -> MLangBlogPost {
        MLangBlogPost().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
