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
    @Published var selectedLangBlogPostIndex = 0
    var selectedLangBlogPost: MLangBlogPost { arrLangBlogPosts[selectedLangBlogPostIndex] }
    func next(_ delta: Int) {
        selectedLangBlogPostIndex = (selectedLangBlogPostIndex + delta + arrLangBlogPosts.count) % arrLangBlogPosts.count
    }

    init(settings: SettingsViewModel, arrLangBlogPosts: [MLangBlogPost], selectedLangBlogPostIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrLangBlogPosts = arrLangBlogPosts
        self.selectedLangBlogPostIndex = selectedLangBlogPostIndex
        super.init()
    }
}
