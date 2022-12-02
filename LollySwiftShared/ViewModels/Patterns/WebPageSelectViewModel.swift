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
import RxBinding

class WebPageSelectViewModel: NSObject {
    let title = BehaviorRelay(value: "")
    let url = BehaviorRelay(value: "")
    var vmSettings: SettingsViewModel
    var arrWebPages = [MWebPage]()
    var selectedWebPage: MWebPage?
    
    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        self.vmSettings = settings
        super.init()
        Task {
            await reload(t: "", u: "")
            complete()
        }
        Observable.combineLatest(title.debounce(.milliseconds(500), scheduler: MainScheduler.instance), url.debounce(.milliseconds(500), scheduler: MainScheduler.instance)).flatMap { (t, u) in self.reload(t: t, u: u) }.subscribe(onNext: { complete() }) ~ rx.disposeBag
    }
    
    func reload(t: String, u: String) async {
        arrWebPages = await MWebPage.getDataBySearch(title: t, url: u)
    }
}
