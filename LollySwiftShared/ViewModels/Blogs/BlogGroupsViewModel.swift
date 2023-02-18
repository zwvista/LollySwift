//
//  BlogGroupsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class BlogGroupsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrBlogGroups = [MBlogGroup]()

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        Task {
            arrBlogGroups = await MBlogGroup.getDataByLang(settings.selectedLang.ID)
            complete()
        }
    }

    static func update(item: MBlogGroup) async {
        await MBlogGroup.update(item: item)
    }

    static func create(item: MBlogGroup) async {
        _ = await MBlogGroup.create(item: item)
    }

    func newBlogGroup() -> MBlogGroup {
        MBlogGroup().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
