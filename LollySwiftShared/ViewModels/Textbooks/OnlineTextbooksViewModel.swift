//
//  OnlineTextbooksViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/11.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class OnlineTextbooksViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrOnlineTextbooks_ = BehaviorRelay(value: [MOnlineTextbook]())
    var arrOnlineTextbooks: [MOnlineTextbook] { get { arrOnlineTextbooks_.value } set { arrOnlineTextbooks_.accept(newValue) } }
    var arrOnlineTextbooksFiltered_ = BehaviorRelay(value: [MOnlineTextbook]())
    var arrOnlineTextbooksFiltered: [MOnlineTextbook] { get { arrOnlineTextbooksFiltered_.value } set { arrOnlineTextbooksFiltered_.accept(newValue) } }
    var selectedOnlineTextbookItem: MOnlineTextbook?
    let indexOnlineTextbookFilter_ = BehaviorRelay(value: 0)
    var indexOnlineTextbookFilter: Int { get { indexOnlineTextbookFilter_.value } set { indexOnlineTextbookFilter_.accept(newValue) } }
    let stringOnlineTextbookFilter_ = BehaviorRelay(value: "")
    var stringOnlineTextbookFilter: String { get { stringOnlineTextbookFilter_.value } set { stringOnlineTextbookFilter_.accept(newValue) } }
    var webTextbookFilter: Int {
        indexOnlineTextbookFilter == -1 ? 0 : vmSettings.arrOnlineTextbookFilters[indexOnlineTextbookFilter].value
    }

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()

        stringOnlineTextbookFilter = vmSettings.arrOnlineTextbookFilters[0].label
        stringOnlineTextbookFilter_.subscribe { [unowned self] s in
            indexOnlineTextbookFilter = vmSettings.arrOnlineTextbookFilters.firstIndex { $0.label == s }!
        } ~ rx.disposeBag
        Observable.combineLatest(arrOnlineTextbooks_, indexOnlineTextbookFilter_).subscribe { [unowned self] _ in
            arrOnlineTextbooksFiltered = webTextbookFilter == 0 ? arrOnlineTextbooks : arrOnlineTextbooks.filter { $0.TEXTBOOKID == webTextbookFilter }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        MOnlineTextbook.getDataByLang(vmSettings.selectedLang.ID).map { [unowned self] in
            arrOnlineTextbooks = $0
        }
    }
}
