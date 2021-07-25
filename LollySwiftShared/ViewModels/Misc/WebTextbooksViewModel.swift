//
//  WebTextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WebTextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWebTextbooks = [MWebTextbook]()
    var arrWebTextbooksFiltered: [MWebTextbook]?

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        MWebTextbook.getDataByLang(settings.selectedLang.ID).subscribe(onSuccess: {
            self.arrWebTextbooks = $0
            self.arrWebTextbooksFiltered = nil
            complete()
        }) ~ rx.disposeBag
    }
    
    func applyFilters(textbookFilter: Int) {
        arrWebTextbooksFiltered = textbookFilter == 0 ? nil : arrWebTextbooks.filter { $0.TEXTBOOKID == textbookFilter }
    }
}
