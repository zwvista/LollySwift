//
//  WebPageSelectViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/23.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class WebPageSelectViewModel: NSObject {
    var title = BehaviorRelay(value: "")
    var url = BehaviorRelay(value: "")
    var vmSettings: SettingsViewModel
    var arrWebPages = [MWebPage]()
    var selectedWebPage: MWebPage?
    
    init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        self.vmSettings = settings
        super.init()
        reload().subscribe(onNext: { complete() }) ~ rx.disposeBag
        Observable.combineLatest(title.debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance), url.debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)).flatMap { (t, u) in self.reload() }.subscribe(onNext: { complete() }) ~ rx.disposeBag
    }
    
    func reload() -> Observable<()> {
        MWebPage.getDataBySearch(title: title.value, url: url.value).map {
            self.arrWebPages = $0
        }
    }

}
