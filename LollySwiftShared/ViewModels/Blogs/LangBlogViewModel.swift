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

    let arrGroupsAll_ = BehaviorRelay(value: [MLangBlogGroup]())
    var arrGroupsAll: [MLangBlogGroup] { get { arrGroupsAll_.value } set { arrGroupsAll_.accept(newValue) } }
    var selectedGroup_ = BehaviorRelay<MLangBlogGroup?>(value: nil)
    var selectedGroup: MLangBlogGroup? { get { selectedGroup_.value } set { selectedGroup_.accept(newValue) } }
    let groupFilter_ = BehaviorRelay(value: "")
    var groupFilter: String { get { groupFilter_.value } set { groupFilter_.accept(newValue) } }
    let arrGroups_ = BehaviorRelay(value: [MLangBlogGroup]())
    var arrGroups: [MLangBlogGroup] { get { arrGroups_.value } set { arrGroups_.accept(newValue) } }
    var hasGroupFilter: Bool { !groupFilter.isEmpty }

    let arrPostsAll_ = BehaviorRelay(value: [MLangBlogPost]())
    var arrPostsAll: [MLangBlogPost] { get { arrPostsAll_.value } set { arrPostsAll_.accept(newValue) } }
    var selectedPost_ = BehaviorRelay<MLangBlogPost?>(value: nil)
    var selectedPost: MLangBlogPost? { get { selectedPost_.value } set { selectedPost_.accept(newValue) } }
    let postFilter_ = BehaviorRelay(value: "")
    var postFilter: String { get { postFilter_.value } set { postFilter_.accept(newValue) } }
    let arrPosts_ = BehaviorRelay(value: [MLangBlogPost]())
    var arrPosts: [MLangBlogPost] { get { arrPosts_.value } set { arrPosts_.accept(newValue) } }
    var hasPostFilter: Bool { !postFilter.isEmpty }

    let postHtml_ = BehaviorRelay(value: "")
    var postHtml: String { get { postHtml_.value } set { postHtml_.accept(newValue) } }

    override init() {
        super.init()

        Observable.combineLatest(arrGroupsAll_, groupFilter_).subscribe { [unowned self] _ in
            arrGroups = !hasGroupFilter ? arrGroupsAll : arrGroupsAll.filter { $0.GROUPNAME.lowercased().contains(groupFilter.lowercased()) }
        } ~ rx.disposeBag
        Observable.combineLatest(arrPostsAll_, postFilter_).subscribe { [unowned self] _ in
            arrPosts = !hasPostFilter ? arrPostsAll : arrPostsAll.filter { $0.TITLE.lowercased().contains(postFilter.lowercased()) }
        } ~ rx.disposeBag
        selectedPost_.flatMap {
            MLangBlogPostContent.getDataById($0?.ID ?? 0)
        }.subscribe { [unowned self] in
            let str = $0?.CONTENT ?? ""
            postHtml = BlogPostEditViewModel.markedToHtml(text: str)
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
