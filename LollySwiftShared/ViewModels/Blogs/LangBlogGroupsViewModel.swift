//
//  LangBlogGroupsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class LangBlogGroupsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrLangBlogGroups = [MLangBlogGroup]()

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        MLangBlogGroup.getDataByLang(settings.selectedLang.ID).subscribe { [unowned self] in
            arrLangBlogGroups = $0
            complete()
        } ~ rx.disposeBag
    }

    static func update(item: MLangBlogGroup) -> Single<()> {
        MLangBlogGroup.update(item: item)
    }

    static func create(item: MLangBlogGroup) -> Single<()> {
        MLangBlogGroup.create(item: item).map { _ in }
    }

    func newLangBlogGroup() -> MLangBlogGroup {
        MLangBlogGroup().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
