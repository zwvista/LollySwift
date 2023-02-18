//
//  BlogGroupViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class BlogGroupViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrBlogGroups = [MBlogGroup]()

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        MBlogGroup.getDataByLang(settings.selectedLang.ID).subscribe { [unowned self] in
            arrBlogGroups = $0
            complete()
        } ~ rx.disposeBag
    }

    static func update(item: MBlogGroup) -> Single<()> {
        MBlogGroup.update(item: item)
    }

    static func create(item: MBlogGroup) -> Single<Int> {
        MBlogGroup.create(item: item)
    }

    func newBlogGroup() -> MBlogGroup {
        MBlogGroup().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
