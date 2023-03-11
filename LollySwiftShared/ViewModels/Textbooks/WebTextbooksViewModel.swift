//
//  WebTextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class WebTextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWebTextbooks_ = BehaviorRelay(value: [MWebTextbook]())
    var arrWebTextbooks: [MWebTextbook] { get { arrWebTextbooks_.value } set { arrWebTextbooks_.accept(newValue) } }
    var arrWebTextbooksFiltered_ = BehaviorRelay(value: [MWebTextbook]())
    var arrWebTextbooksFiltered: [MWebTextbook] { get { arrWebTextbooksFiltered_.value } set { arrWebTextbooksFiltered_.accept(newValue) } }
    let indexWebTextbookFilter_ = BehaviorRelay(value: 0)
    var indexWebTextbookFilter: Int { get { indexWebTextbookFilter_.value } set { indexWebTextbookFilter_.accept(newValue) } }
    let stringWebTextbookFilter_ = BehaviorRelay(value: "")
    var stringWebTextbookFilter: String { get { stringWebTextbookFilter_.value } set { stringWebTextbookFilter_.accept(newValue) } }
    var webTextbookFilter: Int {
        indexWebTextbookFilter == -1 ? 0 : vmSettings.arrWebTextbookFilters[indexWebTextbookFilter].value
    }

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()

        stringWebTextbookFilter = vmSettings.arrWebTextbookFilters[0].label
        stringWebTextbookFilter_.subscribe { [unowned self] s in
            indexWebTextbookFilter = vmSettings.arrWebTextbookFilters.firstIndex { $0.label == s }!
        } ~ rx.disposeBag
        Observable.combineLatest(arrWebTextbooks_, indexWebTextbookFilter_).subscribe { [unowned self] _ in
            arrWebTextbooksFiltered = webTextbookFilter == 0 ? arrWebTextbooks : arrWebTextbooks.filter { $0.TEXTBOOKID == webTextbookFilter }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        MWebTextbook.getDataByLang(vmSettings.selectedLang.ID).map { [unowned self] in
            arrWebTextbooks = $0
        }
    }
}
