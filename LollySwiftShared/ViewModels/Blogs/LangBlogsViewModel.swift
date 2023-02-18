//
//  LangBlogsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class LangBlogsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrLangBlogs = [MLangBlog]()

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        MLangBlog.getDataByLang(settings.selectedLang.ID).subscribe { [unowned self] in
            arrLangBlogs = $0
            complete()
        } ~ rx.disposeBag
    }

    static func update(item: MLangBlog) -> Single<()> {
        MLangBlog.update(item: item)
    }

    static func create(item: MLangBlog) -> Single<()> {
        MLangBlog.create(item: item).map { _ in }
    }

    func newLangBlog() -> MLangBlog {
        MLangBlog().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
