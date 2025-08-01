//
//  TextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/05/20.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding
import Then

class TextbooksViewModel: NSObject {

    var arrTextbooks = [MTextbook]()

    static func update(item: MTextbook) -> Single<()> {
        MTextbook.update(item: item)
    }

    static func create(item: MTextbook) -> Single<()> {
        MTextbook.create(item: item).map { _ in }
    }

    func newTextbook() -> MTextbook {
        MTextbook().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }

    func reload() -> Single<()> {
        MTextbook.getDataByLang(vmSettings.selectedLang.ID, arrUserSettings: vmSettings.arrUserSettings).map { [unowned self] in
            arrTextbooks = $0
        }
    }
}
