//
//  LangBlogPostsContentViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import Combine

@MainActor
class LangBlogPostsContentViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var vmGroups: LangBlogGroupsViewModel
    @Published var arrPosts = [MLangBlogPost]()
    @Published var selectedPostIndex = 0
    var selectedPost: MLangBlogPost { arrPosts[selectedPostIndex] }
    func next(_ delta: Int) {
        selectedPostIndex = (selectedPostIndex + delta + arrPosts.count) % arrPosts.count
    }

    var subscriptions = Set<AnyCancellable>()

    init(settings: SettingsViewModel, vmGroups: LangBlogGroupsViewModel, arrPosts: [MLangBlogPost], selectedPostIndex: Int) {
        vmSettings = settings
        self.vmGroups = vmGroups
        self.arrPosts = arrPosts
        self.selectedPostIndex = selectedPostIndex
        super.init()
        $selectedPostIndex.didSet.sink { [unowned self] _ in
            vmGroups.selectedPost = selectedPost
        } ~ subscriptions
    }
}
