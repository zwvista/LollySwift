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
import NSObject_Rx
import RxBinding

@MainActor
class LangBlogPostsContentViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    var vmGroups: LangBlogGroupsViewModel
    var arrPosts = [MLangBlogPost]()
    var selectedPostIndex_ = BehaviorRelay(value: 0)
    var selectedPostIndex: Int { get { selectedPostIndex_.value } set { selectedPostIndex_.accept(newValue) } }
    var selectedPost: MLangBlogPost { arrPosts[selectedPostIndex] }
    func next(_ delta: Int) {
        selectedPostIndex = (selectedPostIndex + delta + arrPosts.count) % arrPosts.count
    }

    init(settings: SettingsViewModel, vmGroups: LangBlogGroupsViewModel, arrPosts: [MLangBlogPost], selectedPostIndex: Int) {
        vmSettings = settings
        self.vmGroups = vmGroups
        self.arrPosts = arrPosts
        super.init()
        self.selectedPostIndex = selectedPostIndex
        selectedPostIndex_.subscribe { [unowned self] _ in
            vmGroups.selectedPost = selectedPost
        } ~ rx.disposeBag
    }
}
