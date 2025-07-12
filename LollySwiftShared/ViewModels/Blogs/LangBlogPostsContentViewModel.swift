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
    var selectedLangBlogPostIndex_ = BehaviorRelay(value: 0)
    var selectedLangBlogPostIndex: Int { get { selectedLangBlogPostIndex_.value } set { selectedLangBlogPostIndex_.accept(newValue) } }
    var selectedLangBlogPost: MLangBlogPost { arrLangBlogPosts[selectedLangBlogPostIndex] }
    func next(_ delta: Int) {
        selectedLangBlogPostIndex = (selectedLangBlogPostIndex + delta + arrLangBlogPosts.count) % arrLangBlogPosts.count
    }

    init(settings: SettingsViewModel, arrLangBlogPosts: [MLangBlogPost], selectedLangBlogPostIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrLangBlogPosts = arrLangBlogPosts
        super.init()
        self.selectedLangBlogPostIndex = selectedLangBlogPostIndex
    }
}
