//
//  LangBlogPostsContentViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

@MainActor
class LangBlogPostsContentViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var arrLangBlogPosts = [MLangBlogPost]()
    @Published var currentLangBlogPostIndex = 0
    var currentLangBlogPost: MLangBlogPost { arrLangBlogPosts[currentLangBlogPostIndex] }
    func next(_ delta: Int) {
        currentLangBlogPostIndex = (currentLangBlogPostIndex + delta + arrLangBlogPosts.count) % arrLangBlogPosts.count
    }

    init(settings: SettingsViewModel, arrLangBlogPosts: [MLangBlogPost], currentLangBlogPostIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrLangBlogPosts = arrLangBlogPosts
        self.currentLangBlogPostIndex = currentLangBlogPostIndex
        super.init()
    }
}
