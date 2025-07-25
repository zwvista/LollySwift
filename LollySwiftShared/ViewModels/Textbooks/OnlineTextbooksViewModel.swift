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
    var arrOnlineTextbooksAll_ = BehaviorRelay(value: [MOnlineTextbook]())
    var arrOnlineTextbooksAll: [MOnlineTextbook] { get { arrOnlineTextbooksAll_.value } set { arrOnlineTextbooksAll_.accept(newValue) } }
    var arrOnlineTextbooks_ = BehaviorRelay(value: [MOnlineTextbook]())
    var arrOnlineTextbooks: [MOnlineTextbook] { get { arrOnlineTextbooks_.value } set { arrOnlineTextbooks_.accept(newValue) } }
    var selectedOnlineTextbookItem: MOnlineTextbook?
    let indexOnlineTextbookFilter_ = BehaviorRelay(value: 0)
    var indexOnlineTextbookFilter: Int { get { indexOnlineTextbookFilter_.value } set { indexOnlineTextbookFilter_.accept(newValue) } }
    let stringOnlineTextbookFilter_ = BehaviorRelay(value: "")
    var stringOnlineTextbookFilter: String { get { stringOnlineTextbookFilter_.value } set { stringOnlineTextbookFilter_.accept(newValue) } }
    var onlineTextbookFilter: Int {
        indexOnlineTextbookFilter == -1 ? 0 : vmSettings.arrOnlineTextbookFilters[indexOnlineTextbookFilter].value
    }

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()

        stringOnlineTextbookFilter = vmSettings.arrOnlineTextbookFilters[0].label
        stringOnlineTextbookFilter_.subscribe { [unowned self] s in
            indexOnlineTextbookFilter = vmSettings.arrOnlineTextbookFilters.firstIndex { $0.label == s }!
        } ~ rx.disposeBag
        Observable.combineLatest(arrOnlineTextbooksAll_, indexOnlineTextbookFilter_).subscribe { [unowned self] _ in
            arrOnlineTextbooks = onlineTextbookFilter == 0 ? arrOnlineTextbooksAll : arrOnlineTextbooksAll.filter { $0.TEXTBOOKID == onlineTextbookFilter }
        } ~ rx.disposeBag

        reload().subscribe { _ in complete() } ~ rx.disposeBag
    }

    func reload() -> Single<()> {
        MOnlineTextbook.getDataByLang(vmSettings.selectedLang.ID).map { [unowned self] in
            arrOnlineTextbooksAll = $0
        }
    }
}
