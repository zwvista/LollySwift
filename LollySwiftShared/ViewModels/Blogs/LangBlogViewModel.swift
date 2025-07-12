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
    @Published var arrGroups = [MLangBlogGroup]()
    var selectedGroup: MLangBlogGroup? = nil

    @Published var arrPosts = [MLangBlogPost]()
    var selectedPost: MLangBlogPost? = nil
    @Published var postFilter = ""
    @Published var arrPostsFiltered = [MLangBlogPost]()
    var hasPostFilter: Bool { !postFilter.isEmpty }
    var postContent = ""

    var subscriptions = Set<AnyCancellable>()

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()

        $arrPosts.didSet.combineLatest($postFilter.didSet).sink { [unowned self] _ in
            arrPostsFiltered = !hasPostFilter ? arrPosts : arrPosts.filter { $0.TITLE.lowercased().contains(postFilter.lowercased()) }
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
