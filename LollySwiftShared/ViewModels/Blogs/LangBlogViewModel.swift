//
//  LangBlogViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import Combine
import Then

@MainActor
class LangBlogViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var arrGroupsAll = [MLangBlogGroup]()
    @Published var selectedGroup: MLangBlogGroup? = nil
    @Published var groupFilter = ""
    @Published var arrGroups = [MLangBlogGroup]()
    var hasGroupFilter: Bool { !groupFilter.isEmpty }

    @Published var arrPostsAll = [MLangBlogPost]()
    @Published var selectedPost: MLangBlogPost? = nil
    @Published var postFilter = ""
    @Published var arrPosts = [MLangBlogPost]()
    var hasPostFilter: Bool { !postFilter.isEmpty }

    @Published var postHtml = ""

    var subscriptions = Set<AnyCancellable>()

    init(settings: SettingsViewModel) {
        vmSettings = settings
        super.init()

        $arrGroupsAll.didSet.combineLatest($groupFilter.didSet).sink { [unowned self] _ in
            arrGroups = !hasGroupFilter ? arrGroupsAll : arrGroupsAll.filter { $0.GROUPNAME.lowercased().contains(groupFilter.lowercased()) }
        } ~ subscriptions
        $arrPostsAll.didSet.combineLatest($postFilter.didSet).sink { [unowned self] _ in
            arrPosts = !hasPostFilter ? arrPostsAll : arrPostsAll.filter { $0.TITLE.lowercased().contains(postFilter.lowercased()) }
        } ~ subscriptions
        $selectedPost.didSet.sink { [unowned self] post in
            Task {
                let str = (await MLangBlogPostContent.getDataById(post?.ID ?? 0))?.CONTENT ?? ""
                postHtml = BlogPostEditViewModel.markedToHtml(text: str)
            }
        } ~ subscriptions
    }

    static func updateGroup(item: MLangBlogGroup) async {
        await MLangBlogGroup.update(item: item)
    }

    static func createGroup(item: MLangBlogGroup) async {
        _ = await MLangBlogGroup.create(item: item)
    }

    func newGroup() -> MLangBlogGroup {
        MLangBlogGroup().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }

    static func updatePost(item: MLangBlogPost) async {
        await MLangBlogPost.update(item: item)
    }

    static func createPost(item: MLangBlogPost) async -> Int {
        await MLangBlogPost.create(item: item)
    }

    func newPost() -> MLangBlogPost {
        MLangBlogPost().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
