//
//  WebTextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding

class WebTextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWebTextbooks = [MWebTextbook]()
    var arrWebTextbooksFiltered: [MWebTextbook]?

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        MWebTextbook.getDataByLang(settings.selectedLang.ID).subscribe { [unowned self] in
            arrWebTextbooks = $0
            arrWebTextbooksFiltered = nil
            complete()
        } ~ rx.disposeBag
    }

    func applyFilters(textbookFilter: Int) {
        arrWebTextbooksFiltered = textbookFilter == 0 ? nil : arrWebTextbooks.filter { $0.TEXTBOOKID == textbookFilter }
    }

    static func update(item: MWebTextbook) -> Single<()> {
        MWebTextbook.update(item: item)
    }

    static func create(item: MWebTextbook) -> Single<()> {
        MWebTextbook.create(item: item).map { _ in }
    }

    func newWebTextbook() -> MWebTextbook {
        MWebTextbook().then {
            $0.LANGID = vmSettings.selectedLang.ID
        }
    }
}
