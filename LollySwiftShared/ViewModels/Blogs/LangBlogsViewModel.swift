//
//  LangBlogsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import Then

@MainActor
class LangBlogsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrLangBlogs = [MLangBlog]()

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        Task {
            arrLangBlogs = await MLangBlog.getDataByLang(settings.selectedLang.ID)
            complete()
        }
    }

    static func update(item: MLangBlog) async {
        await MLangBlog.update(item: item)
    }

    static func create(item: MLangBlog) async {
        _ = await MLangBlog.create(item: item)
    }

    func newLangBlog() -> MLangBlog {
        MLangBlog().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
