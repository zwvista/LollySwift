//
//  LangBlogPostsContentViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

@MainActor
class LangBlogPostsContentViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    var arrLangBlogPosts = [MLangBlogPost]()
    var currentLangBlogPostIndex_ = BehaviorRelay(value: 0)
    var currentLangBlogPostIndex: Int { get { currentLangBlogPostIndex_.value } set { currentLangBlogPostIndex_.accept(newValue) } }
    var currentLangBlogPost: MLangBlogPost { arrLangBlogPosts[currentLangBlogPostIndex] }
    func next(_ delta: Int) {
        currentLangBlogPostIndex = (currentLangBlogPostIndex + delta + arrLangBlogPosts.count) % arrLangBlogPosts.count
    }

    init(settings: SettingsViewModel, arrLangBlogPosts: [MLangBlogPost], currentLangBlogPostIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrLangBlogPosts = arrLangBlogPosts
        super.init()
        self.currentLangBlogPostIndex = currentLangBlogPostIndex
    }
}
