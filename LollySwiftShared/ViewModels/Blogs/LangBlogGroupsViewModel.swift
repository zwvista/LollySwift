//
//  LangBlogGroupsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class LangBlogGroupsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrLangBlogGroups = [MLangBlogGroup]()

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        Task {
            arrLangBlogGroups = await MLangBlogGroup.getDataByLang(settings.selectedLang.ID)
            complete()
        }
    }

    static func update(item: MLangBlogGroup) async {
        await MLangBlogGroup.update(item: item)
    }

    static func create(item: MLangBlogGroup) async {
        _ = await MLangBlogGroup.create(item: item)
    }

    func newLangBlogGroup() -> MLangBlogGroup {
        MLangBlogGroup().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
